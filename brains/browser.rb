
class DirBrowser < Shoes::Widget
	include Observable
	
	def initialize(path)
		
		@homedir = File.expand_path(File.dirname(__FILE__))
		@okfiles = [/.mp3/, /.flac/, /.ogg/, /.wav/]
		@selected = []
		
		@win = Gtk::Window.new
		@win.set_size_request(750, 450)
                @win.icon = Gdk::Pixbuf.new File.join(DIR, '../static/gshoes-icon.png')
                @win.title = 'Directory Browser'
		
		## rightside TreeView
		@list = Gtk::ListStore.new(String, String)
		@view = Gtk::TreeView.new(@list)
		@view.reorderable=(false)
		@view.enable_search=(true)
		@view.headers_visible=(false)
		@renderer = Gtk::CellRendererText.new
		@column = Gtk::TreeViewColumn.new("", @renderer, :text => 0)
		@view.append_column(@column)
		@listselection = @view.selection
		@listselection.mode=(Gtk::SELECTION_MULTIPLE)
		@view.signal_connect("row-activated"){|view, path, column|
			right_select(path.indices[0])
			add_btns_active(false)
		}
		@listselection.signal_connect("changed"){add_btns_active(true)}
		
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
		@left.set_size_request(200, 450)
		
		current_btn_frame = Gtk::Frame.new()
		@current_dir_btn = Gtk::EventBox.new()
		@current_dir_btn.set_size_request(200, 200)
		@img = Gtk::Image.new()
		@current_dir_btn.add(@img)
		@current_dir_btn.signal_connect("button_press_event"){
			@listselection.select_all
		}
		current_btn_frame.add(@current_dir_btn)
		
		up_btn_frame = Gtk::Frame.new("/../")
		up_btn_frame.label_xalign = 0.05
		@up_dir_btn = Gtk::EventBox.new()
		@current_dir_text = Gtk::Label.new()
		@current_dir_text.width_chars = (26)
		@current_dir_text.set_wrap(true)
		@current_dir_text.justify = Gtk::JUSTIFY_CENTER
		@current_dir_text.ypad = 5
		@up_dir_btn.add(@current_dir_text)
		@up_dir_btn.signal_connect("button_press_event"){up_one_dir}
		up_btn_frame.add(@up_dir_btn)
		
		add_btns_box = Gtk::HBox.new(true, 2)
		@append_btn = Gtk::Button.new("list <<")
		@append_btn.signal_connect("clicked"){add_selection("append")}
		@prepend_btn = Gtk::Button.new(">> list")
		@prepend_btn.signal_connect("clicked"){add_selection("prepend")}
		@append_btn.sensitive = false
		@prepend_btn.sensitive = false
		add_btns_box.pack_start(@append_btn, true, true, 2)
		add_btns_box.pack_start(@prepend_btn, true, true, 2)

		@left.pack_start(current_btn_frame, false, false, 10)
		@left.pack_start(up_btn_frame, false, false, 10)
		@left.pack_end(add_btns_box, false, false, 10)
		
		## main panel
		@leftalign = Gtk::Alignment.new(0.5, 0, 0, 0)
		@leftalign.add(@left)
		@rightalign = Gtk::Alignment.new(0, 0, 1, 0)
		@rightalign.add(@right)
		
		@main.pack_start(@leftalign, true, true, 2)
		@main.pack_start(@rightalign, true, true, 2)
		
		@win.add(@main)
		
		pathscan(path)
		update_ui
		
		@win.show_all
		
	end
	
	def update_ui
		@current_dir_btn.remove(@img)
		pbuf = Gdk::Pixbuf.new(@image_file, 200, 200)
		@img = Gtk::Image.new(pbuf)
		@current_dir_btn.add(@img)
		@current_dir_text.text = @current_dir
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
			update_dir(@dirs[index])
		elsif @files.include?(@files[index - @dirs.length])
			changed; notify_observers([@files[index - @dirs.length], "LIST:PLAY_NOW"])
		end
	end
	
	def up_one_dir
		newpath = @current_dir.split(File::Separator)[0..-2].join(File::Separator)
		update_dir(newpath)
		add_btns_active(false)
	end
	
	def update_dir(path)
		pathscan(path)
		update_ui
	end
	
	def add_btns_active(boolean)
		@append_btn.sensitive = boolean
		@prepend_btn.sensitive = boolean
	end
	
	def add_selection(position)
		dirs = []
		files = []
		@listselection.selected_each{|mod, path, iter|
			dirs << iter[1] ? File.directory?(iter[1]) : files << iter[1]
		}
		
		files.each{|file| @selected << file} if files[0]		
		
		if dirs[0]
			dirs.each{|dir| 
				Find.find(dir){|item|
				@okfiles.each{|ok| @selected << item if item.downcase =~ ok}
				}	
			}
		end
		
		if position == "prepend"
			@selected << "LIST:PREPEND"
		else
			@selected << "LIST:APPEND"
		end
		
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