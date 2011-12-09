require 'gst'
require 'observer'

module Wax

  include Observable
  
  attr_reader :wax_coverart, :wax_duration, :wax_state, :wax_pipeline,
  :wax_shuffle, :wax_atbat, :wax_settings
  attr_accessor :wax_batter, :wax_lineup, :wax_lupine, :wax_roster, :wax_info
  
  #----------------------
  #  INITIALIZE
  #----------------------
  
  def init_wax
    @brainsdir = File.dirname(File.expand_path(__FILE__))
    @settings_file = File.join(@brainsdir, "settings", "settings.txt")
    read_wax_settings
    @wax_roster = @wax_settings[0]
    @wax_lineup = []
    @wax_pipeline = Gst::ElementFactory.make("playbin2")
    @wax_state = "stopped"
    @wax_info = ""
    @titleformat = @wax_settings[3]
    if @wax_settings[1] == "shuffle on"
      @wax_shuffle = true
    else
      @wax_shuffle = false
    end
    @wax_batter = 0 if @wax_batter == nil
    read_wax_lineup
  end
  
  def read_wax_settings
    @wax_settings = []
    File.open(@settings_file, "r"){|file|
      file.each_line{|line| @wax_settings << line.chomp}
    }
  end

  def read_wax_lineup
    @wax_lineup = []
    if File.exists?(@wax_roster)
      list = File.open(@wax_roster, 'r+')
      list.each{|line| @wax_lineup << line.chomp}
      list.close
    else
      @wax_info = "no valid playlist to load"
      send_wax_info("wax_info")
    end
    @wax_lineup.compact!
    @wax_lupine = []
    batter_up_wax
  end
  
  def batter_up_wax
    @wax_lupine = @wax_lineup.shuffle if @wax_lupine.empty?
    if @wax_shuffle
      @wax_atbat = @wax_lupine[@wax_batter] 
    else
      @wax_atbat = @wax_lineup[@wax_batter]
    end
    
    if @wax_atbat
      get_wax_cover(@wax_atbat)
    else
      @wax_coverart = File.join(@brainsdir, "images", "no_cover.jpg")
    end
    
  end
  
  def get_wax_cover(path)
    dir = File.dirname(path)
    Dir.chdir(dir)
    files = Dir['*.{jpg,JPG,png,PNG,gif,GIF}']
    @wax_coverart = File.join(dir, files[0]) if files[0]
  end
  
  
  #-----------------------------------------------------------
  #  PLAY / GET DURATION / GET TAGS
  #-----------------------------------------------------------
  
  def play_wax
    if @wax_lineup.empty?
      batter_up_wax
    end
    if @wax_atbat
      if File.exists?(@wax_atbat)
        @wax_pipeline.uri= GLib.filename_to_uri(@wax_atbat)
        bus = @wax_pipeline.bus
        @tagMsg = []
        
        bus.add_watch {|bus, message|
          case message.type
            when Gst::Message::ERROR
              p message.parse
            when Gst::Message::EOS
              next_wax
              send_wax_info("eos")
            when Gst::Message::TAG
              @tagMsg << message.structure.entries
              get_wax_tags
          end
          true
        }
        
        @wax_pipeline.play
        @wax_state = "playing"
        get_wax_duration
      end
    
    else
      @wax_info = "no track"
      send_wax_info("wax_info")
      
    end
  end
  
  
  def get_wax_duration
    now = Time.now.sec.to_f
    now = 0.0 if now == 59.0
    @limit = now + 2.0
    
    GLib::Timeout.add(100){
      @qd = Gst::QueryDuration.new(Gst::Format::Type::TIME)
      @wax_pipeline.query(@qd)
      @wax_duration = @qd.parse[1]/1000000000
      if @wax_duration > 0
        false
      elsif
        Time.now.sec.to_f > @limit
        false
      else
        true
      end
    }
  end
  
  
  def get_wax_tags
    @gotTags = false
    @tags = @tagMsg.flatten
    
    if @tags.include?("title")
      @title = @tags[@tags.index("title") + 1]; @gotTags = true
    else @title = nil; end
    if @tags.include?("artist")
      @artist = @tags[@tags.index("artist") + 1]; @gotTags = true
    else @artist = nil; end
    if @tags.include?("album")
      @album = @tags[@tags.index("album") + 1]; @gotTags = true
    else @album = nil; end
    if @tags.include?("comments")
      @comments = @tags[@tags.index("comments") + 1]; @gotTags = true
    else @comments = nil; end
    if @tags.include?("track-number")
      @tracknumber = @tags[@tags.index("track-number") + 1]; @gotTags = true
    else @tracknumber = nil; end
    if @tags.include?("genre")
      @genre = @tags[@tags.index("genre") + 1]; @gotTags = true
    else @genre = nil; end
    if @tags.include?("album-artist")
      @albumartist = @tags[@tags.index("album-artist") + 1]; @gotTags = true
    else @albumartist = nil; end
  
    split = @titleformat.split("#")
    @infoentries = []
    split.each{|i|
      i = @title if i == "title"
      i = @album if i == "album"
      i = @artist if i == "artist"
      i = @genre if i == "genre"
      i = @albumartist if i == "album-artist"
      i = @tracknumber if i == "track-number"
      i = @comments if i == "comments"
      @infoentries << i
    }
  
    if @gotTags == false
      @wax_info = File.basename(@wax_atbat)
      send_wax_info("wax_info")
    else
      @infoentries.compact!
      @wax_info = @infoentries.join
      send_wax_info("wax_info")
    end
    
  end #get_wax_tags
  
  
  #-----------------------
  #  TRANSPORT
  #-----------------------
  
  def playpause_wax
    if @wax_atbat
      
      if @wax_state == "stopped"
        play_wax
      elsif @wax_state == "paused"
        resume_wax
      else
        pause_wax
      end
      
    else
      @wax_info = "no track"
      send_wax_info("wax_info")
    end
  end

  def next_wax
    @wax_pipeline.stop
    @wax_batter += 1
    batter_up_wax
    play_wax
  end

  def prev_wax
    @wax_pipeline.stop
    @wax_batter -= 1
    batter_up_wax
    play_wax
  end

  def pause_wax
    @wax_pipeline.pause if @wax_pipeline
    @wax_state = "paused"
  end

  def resume_wax
    @wax_pipeline.play
    @wax_state = "playing"
  end
  
  def stop_wax
    @wax_pipeline.stop if @wax_pipeline
    @wax_state = "stopped"
  end
  
  def toggle_wax_shuffle
    @wax_batter = @wax_lineup.index(@wax_atbat)
    if @wax_shuffle
      @wax_shuffle = false
    else
      @wax_shuffle = true
    end
  end


  #------------------------------------
  #  SEEK / SEND / SAVE
  #------------------------------------
  
  def seek_to_wax(position_in_ms)
    if @wax_pipeline# != nil
      @wax_pipeline.send_event(Gst::EventSeek.new(1.0, 
      Gst::Format::Type::TIME, 
      Gst::Seek::FLAG_FLUSH.to_i | Gst::Seek::FLAG_KEY_UNIT.to_i, 
      Gst::Seek::TYPE_SET, position_in_ms * 1000000, Gst::Seek::TYPE_NONE, -1))
    end
  end


  def send_wax_info(info)
    changed
    notify_observers(info)
  end
  

  def save_wax_settings(settings)
    settings[0] = @wax_roster
    if @wax_shuffle == true
      settings[1] = "shuffle on"
    else
      settings[1] = "shuffle off"
    end
    settings[2] = @wax_atbat
  
    File.open(@settings_file, "w"){|file|
      settings.each{|entry| file.puts(entry)}
    }
  end
  

end  #module
