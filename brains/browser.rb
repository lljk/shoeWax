require 'find'

class BrowserListManager < Shoes::Widget
  include Observable
  def initialize(array, selected=[])
    @selected = selected
    stack{
      array.each{|entry|
        flow width: 1.0, height: 25 do
            txt = para File.basename(entry), stroke: gray
          click{
            unless @selected.include?(entry)
              txt.style(stroke: yellow)
              changed; notify_observers(entry)
            else
              txt.style(stroke: gray)
              changed; notify_observers("unselect:#{entry}")
            end
          }
        end
      }
    }
  end
end  #class ListManager

#---------------------------------------------------------


class DirBrowser < Shoes::Widget
  include Observable
  
  def initialize(path)
    @win = window title: "shoeWax directoryBrowser", width: 820 do

      @homedir = File.expand_path(File.dirname(__FILE__))
      @leftpane = stack width: 200, height: 500
      @rightpane = flow width: -205, height: 500, scroll: true
      @okfiles = %W[.mp3 .flac .ogg .wav]
    
      path = Dir.home unless File.exists?(path)
  
      def showpath(path)
        @selected = []
        @leftpane.clear
        @rightpane.clear
    
        pathscan(path)
    
        leftSide(path)
        rightSideDirs(@dirs) if @dirs[0] != nil
        rightSideFiles(@files) if @files[0] != nil
      end
  
      def pathscan(path)
        dirs = []
        files = []
        Dir.open(path){|dir|
          for entry in dir
            next if entry == '.'
            next if entry == '..'
            item = path + File::Separator + entry
            if File.directory?(item)
              dirs << item
            else
              @okfiles.each{|ok| files << item if item.downcase.include?(ok)}
            end
          end
        }
        @dirs = dirs.sort
        @files = files.sort
      end
  
      def leftSide(path)
        getImage(path)
        @leftpane.append{
          para path, stroke: gray, width: 180, align: "center"
        }
        @leftpane.append{img = image(@img)
          img.style(width: 180, height: 180)
          img.move(8, 190)
        }
        @leftpane.append{
          upbtn = button("up"){
            new = File.split(path)[0]
            showpath(new)
          }
          upbtn.move(75, 380)
      
          appbtn = button("list << dir"){
            addfiles = []
            Find.find(path){|f|
              @okfiles.each{|ok| addfiles << f if f.downcase.include?(ok)}
            }
            addfiles << "LIST:APPEND"
            changed; notify_observers(addfiles)
            new = File.split(path)[0]
            showpath(new)
          }
          appbtn.move(38, 435)
      
          prebtn = button("dir >> list"){
            addfiles = []
            Find.find(path){|f|
              @okfiles.each{|ok| addfiles << f if f.downcase.include?(ok)}
            }
            addfiles << "LIST:PREPEND"
            changed; notify_observers(addfiles)
            new = File.split(path)[0]
            showpath(new)
          }
          prebtn.move(38, 465)
          
        }
      end
  
      def rightSideDirs(dirs)
        dirs.each{|d|
          getImage(d)
          @rightpane.append{
            s = stack width:200 do
            i = image(@img)
            i.style(width: 190, height: 190, align: "center")
            para File.basename(d), stroke: gray, align: "center"
            end
            s.click{showpath(d)}
          }
        }
      end
  
      def rightSideFiles(files)
        @rightpane.clear
        @rightpane.append{
          th = (parent.height * 0.9).round.to_i
          bh = (parent.height * 0.1).round.to_i
          top = stack width: 1.0, height: th, scroll: true
          bottom = stack width: 1.0, height: bh, stroke: gray
        
          top.append{
            lm = browser_list_manager(files)
            lm.add_observer(self)
          }
      
          bottom.append{
            btns = flow{
        
              button("list << tracks"){
                @selected << "LIST:APPEND"
                changed; notify_observers(@selected)
                @selected = []
                rightSideFiles(files)
              }
        
              button("tracks >> list"){
                @selected << "LIST:PREPEND"
                changed; notify_observers(@selected)
                @selected = []
                rightSideFiles(files)
              }
  
            }
            btns.style(top: 10, left: 20)
          }
        }
      end
  
      def getImage(path)
        Dir.chdir(path)
        imgfiles = Dir['*.{jpg,JPG,png,PNG,gif,GIF}']
        imgfile = imgfiles[0]
        imgfile = "nofile.jpg" if imgfile == nil
        if File.exist?(imgfile)
          @img = path + File::Separator + imgfile
        else
          @img = @homedir + File::Separator + "images" + File::Separator + "no_cover.jpg"
        end
      end
      
      def update(message)
        if message.include?("unselect")
          index = message.split(":")[-1]
          @selected.delete(index)
        else
        @selected << message
        end
      end
    
      showpath(path)

    end #window

  end #initialize

  def add_observer(observer)
    @win.add_observer(observer)
  end
  
  def close
    @win.close
  end
  
  
end  #class DirBrowser
