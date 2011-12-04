require 'observer'
brainsdir = File.join(File.dirname(File.expand_path(__FILE__)), "brains")
require File.join(brainsdir, "Wax")
require File.join(brainsdir, "volume")
require File.join(brainsdir, "playlist")
require File.join(brainsdir,  "browser")
require File.join(brainsdir, "scrollbox")
require File.join(brainsdir, "settings_manager")

settings_file = File.join(brainsdir, "settings", "settings.txt")
if File.exists?(settings_file)
	settings = []
	File.open(settings_file, "r"){|file|
		file.each_line{|line| settings << line.chomp}
	}
else
	settings = [
		"none", "shuffle off", "none", "#title# - #artist# - #album#",
		"50%", "Arial", "13", "rgb(255, 255, 255)", "rgb(0, 0, 0)", "none"
	]
	File.open(settings_file, "w"){|file|
		settings.each{|line| file.puts line}
	}
end

scl = settings[4]
	case scl
	when "100%"
		imagedir = File.join(brainsdir, "images", "100%")
		scl = 1.0
	when "50%"
		imagedir = File.join(brainsdir, "images", "50%")
		scl = 0.5
	when "35%"
		imagedir = File.join(brainsdir, "images", "35%")
		scl = 0.35
	end
	
#---------------------------------

Shoes.app title: "ShoeWax", width: 728 * scl, height: 592 * scl do

	App.class_eval{attr_accessor :cover; include Observable; include Wax}
	
	init_wax
	
	@brainsdir = brainsdir
	@musicdir = wax_settings[9]
	@imagedir = imagedir
	@back = background wax_settings[8]
	@scale = scl
	@wax_info = "shoeWax"
	
	batter_up_wax
	
	
	#--------------------------
	#  LAYOUT
	#--------------------------
	
	seekarea = rect((325 * @scale).round, (360 * @scale).round, (125 * @scale).round, (125 * @scale).round)
	seekarea.click{seek}
	
	if wax_coverart
		@cover = image(wax_coverart)
	else
		@cover = image File.join(@brainsdir, "images", "no_cover.jpg")
	end
	
	@cover.width = (485.0 * @scale).round
	@cover.height = (485.0 * @scale).round
	@cover.move((49.0 * @scale).round, (51.0 * @scale).round)
	
	@table = image File.join(@imagedir, "stanton.png")
	
	@arm = image File.join(@imagedir, "arm.png")
	@x_arm = (483.0 * @scale).round
	@y_arm = (-303.0 * @scale).round
	@arm.move(@x_arm, @y_arm)
	@arm.rotate(-18.5)
	
	def hover_toggle(btn, hover_img)
		leave_path = btn.path
		hov_path = File.join(@imagedir, hover_img)
		btn.hover{btn.path = hov_path}
		btn.leave{btn.path = leave_path}
	end
	
	
	transport = flow{
		prevbtn = image File.join(@imagedir, "prev.png")
		prevbtn.click{prev_track; track_progress}
		hover_toggle(prevbtn, "prevHOVER.png")
		prevbtn.margin = 2
		
		@playbtn = image File.join(@imagedir, "play.png")
		@playbtn.click{playpause_track; track_progress}
		hover_toggle(@playbtn, "playHOVER.png")
		@playbtn.margin = 2
	
		nextbtn = image File.join(@imagedir, "next.png")
		nextbtn.click{next_track; track_progress}
		hover_toggle(nextbtn, "nextHOVER.png")
		nextbtn.margin = 2
	}
	transport.move((486.0 * @scale).round, (500.0 * @scale).round)
	
	
	if wax_shuffle
		shufbtn = image File.join(@imagedir, "shuffle.png")
		hover_toggle(shufbtn, "shuffleHOVER.png")
	else
		shufbtn = image File.join(@imagedir, "default.png")
		hover_toggle(shufbtn, "defaultHOVER.png")
	end
	
	shufbtn.click{
		toggle_wax_shuffle
		if wax_shuffle
			shufbtn.path = File.join(@imagedir, "shuffle.png")
			hover_toggle(shufbtn, "shuffleHOVER.png")
		else
			shufbtn.path = File.join(@imagedir, "default.png")
			hover_toggle(shufbtn, "defaultHOVER.png")
		end
	}
	shufbtn.move((563.0 * @scale).round, (460.0 * @scale).round)
	
	
	listdb = flow{
		listbtn = image File.join(@imagedir, "playlist.png")
		listbtn.click{
			if Shoes.APPS.to_s.include?("playList")
				@playlist.close
			else
				playlist(wax_lineup)
			end
		}
		hover_toggle(listbtn, "playlistHOVER.png")
		listbtn.margin = 2
	
		dbbtn = image File.join(@imagedir, "dugout.png")
		dbbtn.click{
			if Shoes.APPS.to_s.include?("directoryBrowser")
				@browser.close
			else
				browser(@musicdir)
			end
		}
		hover_toggle(dbbtn, "dugoutHOVER.png")
		dbbtn.margin = 2
	}
	listdb.move((14.0 * @scale).round, (518.0 * @scale).round)
	
	
	setbtn = image File.join(@imagedir, "settings.png")
	setbtn.click{
		if Shoes.APPS.to_s.include?("settings")
			@set_man.close
		else
		stack{@set_man = settings_manager; @set_man.add_observer(self)}
		end
	}
	hover_toggle(setbtn, "settingsHOVER.png")
	setbtn.move((87.0 * @scale).round, (23.0 * @scale).round)
	

	
	vb = volume_bar(wax_pipeline, @scale)
	vb.move((630.0 * @scale).round, (280.0 * @scale).round)
	
	
	def show_info_win
		sz = wax_settings[6].to_i
		h = (sz + (21 + ((sz / 7) * 7))).round
		
		@info_win = window title: "shoeWax nowPlaying", height: h, scroll: false do
			background self.owner.wax_settings[8]
			self.owner.instance_variable_set(
				"@info_box", scroll_box(self.owner.wax_info, self.owner.wax_settings[5],
				sz, self.owner.wax_settings[7], self.owner.wax_settings[8])
			)
		end
	end

	show_info_win
	
	infobtn = image File.join(@imagedir, "info.png")
	infobtn.click{
		if Shoes.APPS.to_s.include?("nowPlaying")
			@info_win.close
		else
			stack{show_info_win}
		end
		
	}
	hover_toggle(infobtn, "infoHOVER.png")
	infobtn.move((20.0 * @scale).round, (18.0 * @scale).round)
	

	#-------------------------------------------------------
	#   UPDATE INFO / EOS / PLAYLIST
	#-------------------------------------------------------

	def update(message)
		msg = message[-1] if message.class == Array
		
		case
			
			when message == "wax_info"
			@info_box.show_info(wax_info) if @info_win
			
			when message == "eos"
			if wax_coverart
				@cover.path = wax_coverart
			else
				@cover.path = File.join(@brainsdir, "images", "no_cover.jpg")
			end
			@arm.remove
			@arm = image File.join(@imagedir, "arm.png")
			@arm.move(@x_arm, @y_arm)
			@arm.rotate(-18.5)
			@info_box.show_info(wax_info) if @info_win
			
			when msg == "LIST:APPEND"
			message.pop
			message.each{|e| wax_lineup << e}
			update_playlist(wax_lineup)
			
			when msg == "LIST:PREPEND"
			message.pop
			message.each{|e| wax_lineup.insert(0, e)}
			update_playlist(wax_lineup)
			
			when msg == "LIST:DELTRACKS"
			message.pop
			message.each{|e| wax_lineup.delete(e)}
			update_playlist(wax_lineup)
			
			when msg == "LIST:LOAD"
			self.wax_lineup = []
			message.pop
			f_name = message.pop
			message.each{|e| wax_lineup << e}
			update_playlist(wax_lineup)
			stop_wax
			self.wax_roster = f_name
			read_wax_lineup
			self.wax_batter = 0
			batter_up_wax
			@cover.path = wax_coverart
			@info_box.show_info(File.basename(wax_atbat)) if @info_win
			
			when message == "LIST:CLEAR"
			stop_wax
			wax_lineup.clear
			wax_lupine.clear
			self.wax_batter = 0
			batter_up_wax
			@cover.path = wax_coverart
			@info_box.clear_text if @info_win
			@info_box.show_info("no track") if @info_win
			update_playlist(wax_lineup)
			
			when msg == "LIST:SAVE"
			self.wax_roster = message[0]
			
			when message == "LIST:BROWSER"
			browser(@musicdir)
			
			when msg == "TITLE_FORMAT"
			message.pop
			save_wax_settings(message)
			read_wax_settings
			fill = wax_settings[8]
			if @info_win
				@info_win.close
				show_info_win
				@info_box.set_format(wax_settings[5], wax_settings[6], wax_settings[7], wax_settings[8])
			end
		end	#case
		
	end	#update
	
	
	#-------------------------
	#  TRANSPORT  
	#-------------------------
	
	def playpause_track
		playpause_wax
		if wax_state == "playing"
			@table.path = File.join(@imagedir, "stanton1.png")
			@playbtn.path = File.join(@imagedir, "pause.png")
			@playbtn.hover{@playbtn.path = File.join(@imagedir, "pauseHOVER.png")}
			@playbtn.leave{@playbtn.path = File.join(@imagedir, "pause.png")}
			track_progress
		else
			@table.path = File.join(@imagedir, "stanton.png")
			@playbtn.path = File.join(@imagedir, "play.png")
			@playbtn.hover{@playbtn.path = File.join(@imagedir, "playHOVER.png")}
			@playbtn.leave{@playbtn.path = File.join(@imagedir, "play.png")}
		end
	end
	
	def next_track
		next_wax
		if wax_atbat
			update("eos")
			@table.path = File.join(@imagedir, "stanton1.png")
			@playbtn.path = File.join(@imagedir, "pause.png")
			@playbtn.hover{@playbtn.path = File.join(@imagedir, "pauseHOVER.png")}
			@playbtn.leave{@playbtn.path = File.join(@imagedir, "pause.png")}
			track_progress
		end
	end
	
	def prev_track
		prev_wax
		if wax_atbat
			update("eos")
			@table.path = File.join(@imagedir, "stanton1.png")
			@playbtn.path = File.join(@imagedir, "pause.png")
			@playbtn.hover{@playbtn.path = File.join(@imagedir, "pauseHOVER.png")}
			@playbtn.leave{@playbtn.path = File.join(@imagedir, "pause.png")}
			track_progress
		end
	end
	
	def track_progress
		@timer.remove if @timer
		@timer = animate(4){
			if wax_state == "playing"
				if wax_duration > 0
					degrees = (-5.5 / wax_duration.to_f).round(3)
					@arm.rotate(degrees)
				end
			end
		}
	end
	
	def seek
		if wax_duration
			percent = ((self.mouse[2] - (485.0 * @scale)) * -1) / (124.0 * @scale)
			sought = wax_duration * percent
			seek_to_wax((sought * 1000.0).round)

			@arm.remove
			@arm = image File.join(@imagedir, "arm.png")
			@arm.move(@x_arm, @y_arm)
			@arm.rotate(-18.5 + (percent * -25.0))
		end
		
	end
	
	
	#-----------------------------------------------
	#  PLAYLIST AND BROWSER  
	#-----------------------------------------------
	
	def playlist(list)
		stack{@playlist = play_list}
		@playlist.add(list)
		@playlist.add_observer(self)
	end	
	
	def update_playlist(list)
		@playlist.update_list(list) if Shoes.APPS.to_s.include?("playList")
		self.wax_lineup = list
		self.wax_lupine = list.shuffle
		self.wax_batter = 0
		self.batter_up_wax
		self.cover.path = wax_coverart
	end
	
	
	def browser(basedir)
			stack{@browser = dir_browser(basedir)}
			@browser.add_observer(self)
	end
	
	#---------------------------------
	
	# connect to wax module notifications
	add_observer(self) 
	
	# close all windows and save at shutdown
	transport.finish{
		stop_wax
		save_wax_settings(wax_settings)
		quit
	}
	
end	#Shoes.app

#----------------------------------
#  That's all Folks.... jk
#----------------------------------