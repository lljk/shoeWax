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
        
        main = flow margin_top: 20 do
          flow margin_left: 10 do
          
            left = stack width: btn_width do
            
              stack do
                para "home music directory:", stroke: gray
                hmd_btn = nil
                flow(width: btn_width){
                  hmd_btn = para settings[9]
                }.click{
                  hmd = ask_open_folder
                  hmd_btn.text = settings[9] = hmd if hmd
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
                  background eval(settings[8])
                  border gray
                end

                bg_box.click{
                  bg_color = ask_color("background")
                  settings[8] = bg_color.inspect if bg_color
                  bg_box.clear do
                    background eval(settings[8])
                    border gray
                  end
                }
              end
            
              flow(height: 20){}
              txtc = stack  do
                para "text color:", stroke: gray
                txtc_box = flow width: btn_width, height: 25 do
                  background eval(settings[7])
                  border gray
                end

                txtc_box.click{
                  txtc_color = ask_color("background")
                  settings[7] = txtc_color.inspect if txtc_color
                  txtc_box.clear do
                    background eval(settings[7])
                    border gray
                  end
                }
              end
            
              txts = flow width: btn_width, displace_top: 75 do
                @text_sample = para "The quick brown fox jumped over the lazy dog.", 
                  font: settings[5], stroke: eval(settings[7]), size: settings[6].to_i
              end
            end  #left stack
          
            txt_format = nil
            right = stack width: btn_width do
            
              para "title format:", stroke: gray, stroke: gray

              txt_format = edit_box width: (win.width / 2) - 20
              txt_format.text = settings[3]
            
              flow(height: 5){}
              field = list_box items: ["add field", "#track-number#", "#title#", "#album#", "#artist#", "#album-artist#", "#genre#", "#comments#"], choose: "add field", width: (win.width / 2) - 20
              field.change{|fld| txt_format.text += fld.text unless fld.text == "add field"}
            
              flow(height: 20){}
              stack do
                para "text font:", stroke: gray
                fonts = Shoes::FONTS
                txtfont = list_box items: fonts, choose: settings[5]
                txtfont.style(width: btn_width)
                txtfont.change{
                  settings[5] = txtfont.text
                  @text_sample.style(font: settings[5], stroke: eval(settings[7]), size: settings[6].to_i)
                }
              end
          
              flow(height: 20){}
              flow do
                para "font size:   ", stroke: gray
                size = list_box items: ("7".."28").to_a, choose: settings[6]
                size.change{
                  settings[6] = size.text
                  @text_sample.style(font: settings[5], stroke: eval(settings[7]), size: settings[6].to_i)
                }
              end
          
              flow(height: 20){}
              flow do
                button("save settings"){
                  settings[3] = txt_format.text
                  settings << "TITLE_FORMAT"
                  changed
                  notify_observers(settings)
                  self.close
                }
                button("cancel"){self.close}
              end
            
            end  #right stack
          end
          
        end  #main
        
      end  #init_ui
    
      init_ui(self, settings)
    
    end  #window
    
  end  #initialize
  
  def close
    @win.close
  end
  
  def add_observer(observer)
    @win.add_observer(observer)
  end
  
  
end  #class
