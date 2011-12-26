
class TextSampleBox < Shoes::Widget
	def initialize(width, text_color, bg_color, font, size)
		@box = flow width: width do
			background bg_color
			border gray
			@text_sample = para "The quick brown fox jumped over the lazy dog.", 
			font: font, stroke: text_color, size: size, margin: 10
		end
	end
	
	def update(text_color, bg_color, font, size)
		@box.clear
		@box.append{
			background bg_color
			border gray
			@text_sample = para "The quick brown fox jumped over the lazy dog.", 
			font: font, stroke: text_color, size: size, margin: 10
		}
	end
end

class SettingsManager < Shoes::Widget
  include Observable
  
  def initialize
    homedir = File.dirname(File.expand_path(__FILE__))
    settings = []
		
		if File.exists?(homedir + "/settings/settings.txt")
			File.open(homedir + "/settings/settings.txt", "r"){|file|
				file.each_line{|line| settings << line.chomp}
			}
		else
			settings = [
				"none", "shuffle off", "none", "#title# - #artist# - #album#",
			"50%", "Arial", "13", "255, 255, 255", "0, 0, 0", "none"
			]
			File.open(homedir + "/settings/settings.txt", "w"){|file|
				settings.each{|line| file.puts line}
			}
		end
		
		get_colors(settings)
		background gradient(midnightblue, black)
		btn_width = (self.width / 2) - 20

		main = flow margin_top: 20 do
			flow margin_left: 10 do
			
				left = stack width: btn_width do
				
					stack do
						para "home music directory:", stroke: gray
						hmd_btn = nil
						f = flow(width: btn_width){
							border gray
							hmd_btn = para settings[9], stroke: white, margin: 5, wrap: "trim"
						}.click{
							hmd = ask_open_folder
							hmd_btn.text = settings[9]  = hmd if hmd
							hmd_btn.text = fg(hmd_btn.text, gray)
						}
					end
				
					flow(height: 20){}
					flow do
						para "scale:   ", stroke: gray
						scale = list_box items: ["100%", "50%", "35%"], choose: settings[4]
						scale.change{settings[4] = scale.text}
					end
				
					flow(height: 20){}
					bgc = stack do
						para "background color:", stroke: gray
						bg_box = flow width: btn_width, height: 25 do
							background @bg_color
							border gray
						end

						bg_box.click{
							bg_color = ask_color("background")
							settings[8] = bg_color.inspect[1..-2] if bg_color
							bg_box.clear do
								get_colors(settings)
								background @bg_color
								border gray
								@text_sample.update(@text_color, @bg_color, settings[5], settings[6].to_i)
							end
						}
					end
				
					flow(height: 20){}
					txtc = stack  do
						para "text color:", stroke: gray
						txtc_box = flow width: btn_width, height: 25 do
							background @text_color
							border gray
						end
						
						txtc_box.click{
							txtc_color = ask_color("text")
							settings[7] = txtc_color.inspect[1..-2] if txtc_color
							txtc_box.clear do
								get_colors(settings)
								background @text_color
								border gray
							end
							@text_sample.update(@text_color, @bg_color, settings[5], settings[6].to_i)
						}
					end
					
					flow(height: 20){}
					stack do
						para "text font:", stroke: gray
						fonts = Shoes::FONTS
						txtfont = list_box items: fonts, choose: settings[5]
						txtfont.style(width: btn_width)
						txtfont.change{
							settings[5] = txtfont.text
							@text_sample.update(@text_color, @bg_color, settings[5], settings[6].to_i)
						}
					end
					
					flow(height: 20){}
					flow do
						para "font size:   ", stroke: gray
						size = list_box items: ("7".."28").to_a, choose: settings[6]
						size.change{
							settings[6] = size.text
							@text_sample.update(@text_color, @bg_color, settings[5], settings[6].to_i)
						}
					end
			
					flow(height: 20){}
					flow do
						button("save settings"){
							settings[3] = @txt_format.text
							settings << "TITLE_FORMAT"
							changed
							notify_observers(settings)
							self.close
						}
						button("cancel"){self.close}
					end
					
				end  #left stack
			
				@txt_format = nil
				right = stack width: btn_width do
				
					para "title format:", stroke: gray, stroke: gray

					@txt_format = edit_box width: (self.width / 2) - 20
					@txt_format.text = settings[3]
				
					flow(height: 10){}
					field = list_box items: ["add field", "#track-number#", "#title#", "#album#", "#artist#", "#album-artist#", "#genre#", "#comments#"], choose: "add field", width: (self.width / 2) - 20
					field.change{|fld| @txt_format.text += fld.text unless fld.text == "add field"}
				
				
					flow(height: 50){}
					@text_sample = text_sample_box(btn_width, @text_color, @bg_color, settings[5], settings[6].to_i)
				
				end  #right stack
			end
			
		end  #main

  end  #initialize
	
	def get_colors(settings)
		txt_clr = settings[7].split(',')
		@text_color = rgb(txt_clr[0].to_f.round(3), txt_clr[1].to_f.round(3), txt_clr[2].to_f.round(3))
		bg_clr = settings[8].split(',')
		@bg_color = rgb(bg_clr[0].to_f.round(3), bg_clr[1].to_f.round(3), bg_clr[2].to_f.round(3))
	end

end  #class
