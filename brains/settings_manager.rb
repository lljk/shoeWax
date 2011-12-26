class SettingsManager < Shoes::Widget
	include Observable
	
	def initialize
		homedir = File.dirname(File.expand_path(__FILE__))
		settings = []
		File.open(homedir + "/settings/settings.txt", "r"){|file|
			file.each_line{|line| settings << line.chomp}
		}

		@win = window title: "shoeWax settings", height: 420 do
			@homedir = homedir
		
			def init_ui(win, settings)
				btn_width = (win.width / 2) - 20
				
				main = flow do
					
					left = stack displace_left: 10 do
						
						stack top: 20 do
							para "home music directory:", stroke: gray
							hmd_btn = button(settings[9]){
								hmd = ask_open_folder
								settings[9] = hmd
							}
							hmd_btn.style(width: btn_width)
						end
						
						flow displace_top: 25 do
							para "scale:   ", stroke: gray
							scale = list_box items: ["100%", "50%", "35%"], choose: settings[4]
							scale.change{settings[4] = scale.text}
						end
						
						bgc = stack do
							para "background color:", stroke: gray
							bg_box = rect(10, 30, btn_width, 25)
							bg_box.style(fill: settings[8], stroke: gray)
							bg_box.click{
								bg_color = ask_color("background")
								settings[8] = bg_color
								main.clear
								init_ui(self, settings)
							}
						end
						bgc.move(0, 160)
						
						txtc = stack displace_top: 30 do
							para "text color:", stroke: gray
							txtc_box = rect(10, 60, btn_width, 25)
							txtc_box.style(fill: settings[7], stroke: gray)
							txtc_box.click{
								txt_color = ask_color("text")
								settings[7] = txt_color
								main.clear
								init_ui(self, settings)
							}
						end
						
						txts = flow width: btn_width, displace_top: 75 do
							@text_sample = para "The quick brown fox jumped over the lazy dog."
							@text_sample.style(font: settings[5], stroke: settings[7], size: settings[6])
						end
					end	#left stack
					
					right = stack do
						
						para "title format:", stroke: gray, displace_top: 10, stroke: gray

						txt_format = edit_box width: (win.width / 2) - 20
						txt_format.text = settings[3]
						txt_format.change{settings[3] = txt_format.text}
						
						field = list_box items: ["add field", "#track-number#", "#title#", "#album#", "#artist#", "#album-artist#", "#genre#", "#comments#"], choose: "add field", width: (win.width / 2) - 20
						field.change{|fld|
							txt_format.text += fld.text unless fld.text == "add field"
							fld.choose("add field")
						}
						
						stack displace_top: 20 do
							para "text font:", stroke: gray
							fonts = Shoes::FONTS
							txtfont = list_box items: fonts, choose: settings[5]
							txtfont.style(width: btn_width)
							txtfont.change{
								settings[5] = txtfont.text
								@text_sample.style(font: settings[5], stroke: settings[7], size: settings[6])
							}
						end
					
						flow displace_top: 45 do
							para "font size:   ", stroke: gray
							size = list_box items: ("7".."28").to_a, choose: settings[6]
							size.change{
								settings[6] = size.text
								@text_sample.style(font: settings[5], stroke: settings[7], size: settings[6])
							}
						end
					
						flow displace_left: 65, displace_top: 90 do
							button("save settings"){
								settings << "TITLE_FORMAT"
								changed
								notify_observers(settings)
								self.close
							}
							button("cancel"){self.close}
						end
						
					end	#right stack
					
					right.move(((win.width) / 2) + 5, 0)
				
				end	#main
				
			end	#init_ui
		
			init_ui(self, settings)
		
		end	#window
		
	end	#initialize
	
	def close
		@win.close
	end
	
	def add_observer(observer)
		@win.add_observer(observer)
	end
	
	
end	#class