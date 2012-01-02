
class DirBrowser < Shoes::Widget
	include Observable
	
	def initialize(path)
		
		@homedir = File.expand_path(File.dirname(__FILE__))
		@okfiles = [/.mp3/, /.flac/, /.ogg/, /.wav/]
		@selected = []
		
		@win = Gtk::Window.new
		@win.set_size_request(750, 450)
		
		## rightside TreeView
		@list = Gtk::ListStore.new(String, String)
		@view = Gtk::TreeView.new(@list)
		@view.reorderable=(true)
		@view.enable_search=(true)
		@view.headers_visible=(false)
		@renderer = Gtk::CellRendererText.new
		@column = Gtk::TreeViewColumn.new("", @renderer, :text => 0)
		@view.append_column(@column)
		@listselection = @view.selection
		@listselection.mode=(Gtk::SELECTION_MULTIPLE)
		@view.signal_connect("row-activated"){|view, path, column|
			right_select(path.indices[0])
		}
		
		## main panel
		@main = Gtk::HBox.new(false, 5)
		
		#### right side
		@right = Gtk::VBox.new(false, 2)
		
		@rightpane = Gtk::ScrolledWindow.new
		@rightpane.set_size_request(500, 450)
		horizontal = @rightpane.hadjustment
		vertical = @rightpane.vadjustment
		viewport = Gtk::Viewport.new(horizontal, vertical)
		@rightpane.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS)
		@rightpane.add_with_viewport(@view)
		
		@right.pack_start(@rightpane, true, true, 2)
		
		#### left side
		@left = Gtk::VBox.new(false, 2)
		@left.width_request = 200
		
		up_btn_frame = Gtk::Frame.new("../")
		up_btn_frame.label_xalign = 0.05
		@up_dir_btn = Gtk::EventBox.new()
		@current_dir_text = Gtk::Label.new()
		@current_dir_text.width_chars = (26)
		@current_dir_text.set_wrap(true)
		@current_dir_text.justify = Gtk::JUSTIFY_CENTER
		@up_dir_btn.add(@current_dir_text)
		@up_dir_btn.signal_connect("button_press_event"){up_one_dir}
		up_btn_frame.add(@up_dir_btn)
		
		dir_btn_box = Gtk::HBox.new(true, 2)
		append_btn = Gtk::Button.new("list << dir")
		append_btn.signal_connect("clicked"){append_dir}
		prepend_btn = Gtk::Button.new("dir >> list")
		prepend_btn.signal_connect("clicked"){prepend_dir}
		dir_btn_box.pack_start(append_btn, true, true, 2)
		dir_btn_box.pack_start(prepend_btn, true, true, 2)
		
		@file_btn_box = Gtk::HBox.new(true, 2)
		append_btn1 = Gtk::Button.new("list << files")
		append_btn1.signal_connect("clicked"){append_files}
		prepend_btn1 = Gtk::Button.new("files >> list")
		prepend_btn1.signal_connect("clicked"){prepend_files}
		@file_btn_box.pack_start(append_btn1, true, true, 2)
		@file_btn_box.pack_start(prepend_btn1, true, true, 2)
		@file_btn_box.name = "file_btns"

		@left.pack_end(@file_btn_box, true, true, 0)
		@left.pack_end(dir_btn_box, true, true, 15)
		@left.pack_end(up_btn_frame, true, true, 10)
		
		## main panel
		@leftalign = Gtk::Alignment.new(0.5, 0, 0, 0)
		@rightalign = Gtk::Alignment.new(0, 0, 1, 0)
		
		@leftalign.add(@left)
		@rightalign.add(@right)
		
		@main.pack_start(@leftalign, true, true, 2)
		@main.pack_start(@rightalign, true, true, 2)
		
		@win.add(@main)
		
		pathscan(path)
		update_ui
		
		@win.show_all
		
	end
	
	def update_ui
		
		@left.remove(@img) if @img
		pbuf = Gdk::Pixbuf.new(@image_file, 200, 200)
		@img = Gtk::Image.new(pbuf)
		@left.pack_start(@img, true, true, 2)
		@current_dir_text.text = @current_dir
		@file_btn_box.no_show_all = @files.empty?
		@file_btn_box.hide if @files.empty?
		@left.show_all

		@list.clear
		@dirs.each{|dir| add_to_list(dir)} if @dirs[0]
		@files.each{|file| add_to_list(file)} if @files[0]
		
	end
	
	def add_to_list(entry)
		iter = @list.append
		@list.set_value(iter, 0, File.basename(entry))
		@list.set_value(iter, 1, entry)
	end
	
	def right_select(index)
		if @dirs.include?(@dirs[index])
			pathscan(@dirs[index])
			update_ui
		elsif @files.include?(@files[index - @dirs.length])
			changed; notify_observers([@files[index - @dirs.length], "LIST:PLAY_NOW"])
		end
	end
	
	def up_one_dir
		newpath = @current_dir.split(File::Separator)[0..-2].join(File::Separator)
		update_dir(newpath)
	end
	
	def update_dir(path)
		pathscan(path)
		update_ui
	end
	
	def append_dir
		Find.find(@current_dir){|item|
			@okfiles.each{|ok| @selected << item if item.downcase =~ ok}
		}
		@selected << "LIST:APPEND"
		changed; notify_observers(@selected)
		@selected = []
		
	end
	
	def prepend_dir
		Find.find(@current_dir){|item|
			@okfiles.each{|ok| @selected << item if item.downcase =~ ok}
		}
		@selected << "LIST:PREPEND"
		changed; notify_observers(@selected)
		@selected = []
	end
	
	def append_files
		@listselection.selected_each{|mod, path, iter| @selected << iter[1]}
		@selected << "LIST:APPEND"
		changed; notify_observers(@selected)
		@selected = []
		@listselection.unselect_all
	end
	
	def prepend_files
		@listselection.selected_each{|mod, path, iter| @selected << iter[1]}
		@selected << "LIST:PREPEND"
		changed; notify_observers(@selected)
		@selected = []
		@listselection.unselect_all
	end
	
	def pathscan(path)
		if File.directory?(path)
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
	
end	#DirBrowser