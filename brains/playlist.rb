class ListManager < Shoes::Widget
	include Observable
	attr_accessor :page
	
  def initialize(array)
		@selected = []
		self.show(array)
		keypress{|k|
			case k.to_s.downcase
				when 'up'
					@selected.each{|entry|
						i = array.index(entry)
						array.delete_at(i)
						i -= 1
						array.insert(i, entry)
					}
					@page.clear
					self.show(array)
				when 'down'
					@selected.each{|entry|
						i = array.index(entry)
						array.delete_at(i)
						i += 1
						i = 0 if i > array.length
						array.insert(i, entry)
					}
					@page.clear
					self.show(array)
			end
		}
	end
	
	def show(array)
		@page = stack{
			array.each{|entry|
				cell = flow width: 1.0, height: 25 do # cell not nec?
					if @selected.include?(entry)
						txt = para File.basename(entry), stroke: yellow
					else
						txt = para File.basename(entry), stroke: gray
					end
					click{
						unless @selected.include?(entry)
							@selected << entry
							txt.style(stroke: yellow)
							changed
							notify_observers(entry)
						else
							@selected.delete(entry)
							txt.style(stroke: gray)
							changed
							notify_observers("unselect:#{entry}")
						end
					}
				end
			}
		}
	end
	
end	#class ListManager


#---------------------------------------------------------------


class PlayList < Shoes::Widget
	include Observable
	
	def initialize
		
		@win = window title: "shoeWax playList" do
			App.class_eval{attr_accessor :top}
			
			def init_ui
				@selected = []
		
				th = (self.height * 0.9).round.to_i
				bh = (self.height * 0.1).round.to_i
				@top = stack width: 1.0, height: th, scroll: true
				bottom = stack width: 1.0, height: bh, stroke: gray
			
				bottom.append{
					flow top: 10 do
				
						addbtn = button("add tracks"){
							changed
							notify_observers("LIST:BROWSER")
						}
			
						delbtn = button("remove tracks"){
							@selected << "LIST:DELTRACKS"
							changed
							notify_observers(@selected)
						}
					
						clrbtn = button("clear list"){
							if confirm("remove all tracks?")
								changed
								notify_observers("LIST:CLEAR")
							end
						}
					
						load = button("load list"){
							list = []
							Dir.chdir(File.dirname(File.expand_path(__FILE__)) + "/playlists/")
							o_name = ask_open_file
							File.open(o_name, "r"){|file|
								file.each_line{|line| list << line}
							}
							list << o_name
							list << "LIST:LOAD"
							changed
							notify_observers(list)
						}
					
						save = button("save list"){
							Dir.chdir(File.dirname(File.expand_path(__FILE__)) + "/playlists/")
							s_name = ask_save_file
							if @list
								File.open(s_name, "w"){|file|
									@list.each{|e| file.puts(e)}
								}
							end
							f_name = File.expand_path(s_name)
							changed
							notify_observers([f_name, "LIST:SAVE"])
						}
				
					end
				}
			end	#init_ui
			
		
			def add(list)
				@list = list
				@top.append{
					listman = list_manager(list)
					listman.add_observer(self)
				}
			end
	
			def update(message)
				if message.include?("unselect")
					index = message.split(":")[-1]
					@selected.delete(index)
				else
				@selected << message
				end
			end
		
		end #window
		
		@win.init_ui
	end	#initialize
	
	def update_list(list)
		@win.top.clear
		@win.add(list)
	end
	
	def add(list)
		@win.add(list)
	end
	
	def add_observer(observer)
		@win.add_observer(observer)
	end
	
	def close
		@win.close
	end
	
	
end #class Playlist
