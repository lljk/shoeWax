require 'find'

class DirBrowser < Shoes::Widget
	include Observable
	
	def initialize(path)
		@homedir = File.expand_path(File.dirname(__FILE__))
		@okfiles = [/.mp3/, /.flac/, /.ogg/, /.wav/]
		@selected = []
		pathscan(path)
		init_ui
	end

	def pathscan(path)
		dirs = []
		files = []
		Dir.open(path){|dir|
			for entry in dir
				next if entry == '.'
				next if entry == '..'
				unless entry[0] == '.'
					item = path + File::Separator + entry
					if File.directory?(item)
						dirs << item unless File.basename(item)[0] == "."
					else
						@okfiles.each{|ok| files << item if item.downcase =~ ok}
					end
				end
			end
		}
		@dirs = dirs.sort
		@files = files.sort
		@current_dir = path
		@left_width = (self.width / 4) + 20
		get_image(@current_dir)
	end
	
	def init_ui
		@main = flow do
			
			@leftside = stack(width: 0.25, margin_left: 10){left_side}
			@rightside = flow(width: 0.75, margin_left: 65){right_side}
			
			pinning @leftside
			pinning @current_btn[0]
			pinning @append_btn[1]
			pinning @prepend_btn[2]
			
		end
	end
	
	def left_side

			flow(height: 25){}
			@dir_image = image(@image_file, width: @left_width, height: @left_width)
			
			flow(height: 15){}
			@current_btn = flow(width: @left_width){
				border gray
				@dir_text = para @current_dir.esc_html, align: "center", margin_top: 3
			}.click{
				newpath = @current_dir.split(File::Separator)[0..-2].join(File::Separator)
				update_dir(newpath)
			}
			
			flow(height: 15){}
			@append_btn = flow(width: @left_width){
				border gray
					para "append directory", align: "center", margin_top: 3
			}.click{append_dir}
			
			flow(height: 15){}
			@prepend_btn = flow(width: @left_width){
				border gray
					para "prepend directory", align: "center", margin_top: 3
			}.click{prepend_dir}
		
	end
	
	def right_side
		
		flow(height: 15){}
		@dirs.each{|dir|
			entry = link(span(File.basename(dir).esc_html, foreground: 'black',
			underline: "none"), wrap: "trim"){update_dir(dir)}
			para entry
			flow(height: 5){}
		}
		
		@files.each{|file|
			if @selected.include?(file)
				entry = link(span(File.basename(file).esc_html, foreground: 'blue',
				underline: "none"), wrap: "trim"){
					@selected.delete(file)
					if @selected.empty?
						@addfile_btns.clear; @addfile_btns = nil
					end
					update_ui
				}
				para entry
			else
				entry = link(span(File.basename(file).esc_html, foreground: 'black',
				underline: "none"), wrap: "trim"){
					file_select(file)
				}
				para entry
			end
		}
		
	end
	
	def update_ui
		
		@dir_image.path = @image_file
		@dir_text.text = @current_dir.esc_html
		
		@rightside.clear
		@rightside.append{right_side}
		
	end
	
	def update_dir(dir)
		pathscan(dir)
		update_ui
	end
	
	def file_select(file)
		@selected << file
		update_ui
		
		unless @addfile_btns
			@leftside.append{
				flow(height: 15){}
				@addfile_btns = stack do
					@append_file_btn = flow(width: @left_width){
						border gray
							para "list << files".esc_html, align: "center", margin_top: 3
					}.click{append_files}
					
					flow(height: 15){}
					@prepend_file_btn = flow(width: @left_width){
						border gray
							para "directory >> files".esc_html, align: "center", margin_top: 3
					}.click{prepend_files}
				end
				pinning @append_file_btn[3]
				pinning @prepend_file_btn[4]
			}
			pinning @addfile_btns
		end
	end
	
	def append_dir
		Find.find(@current_dir){|item|
			@okfiles.each{|ok| @selected << item if item.downcase =~ ok}
		}
		append_files
	end
	
	def prepend_dir
		Find.find(@current_dir){|item|
			@okfiles.each{|ok| @selected << item if item.downcase =~ ok}
		}
		prepend_files
	end
	
	def append_files
		@addfile_btns.clear; @addfile_btns = nil
		@selected << "LIST:APPEND"
		changed; notify_observers(@selected)
		@selected = []
		update_ui
	end
	
	def prepend_files
		@addfile_btns.clear
		@selected << "LIST:PREPEND"
		changed; notify_observers(@selected)
		@selected = []
		update_ui
	end
	
	def get_image(path)
		image_files = []
		Dir.entries(path).each{|entry|
			image_files << entry if entry.downcase.include?(".jpg") || entry.downcase.include?(".png") || entry.downcase.include?(".gif")
		}
		if image_files[0]
			@image_file = path + File::Separator + image_files[0]
		else
			@image_file = @homedir + File::Separator + "images" + File::Separator + "no_cover.jpg"
		end
	end

end