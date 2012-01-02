
class ScrollBox < Shoes::Widget
  
  def initialize(txt, fnt, sz, txtclr, bgclr)
		@txtclr = txtclr
    @back = background bgclr
    @box = flow{
      @space = para "", font: fnt, stroke: @txtclr, size: sz, align: "center", wrap: "trim"
    }
    show_info(txt)
  end
  
  def show_info(txt)
    @timer.stop if @timer
    @space.text = fg(txt, @txtclr)
    newtxt = txt + "     "
    
    @box.hover{
      @timer = animate(8){
        @space.text = fg(newtxt, @txtclr)
        first = newtxt.slice!(0)
        newtxt << first
      }
    }
    
    @box.leave{
      @timer.stop if @timer
      @space.text = fg(txt, @txtclr)
      newtxt = txt + "     "
    }
  end
  
  def set_format(fnt, sz, txtclr, bgclr)
		@back.style(fill: bgclr)
    @space.style(font: fnt, size: sz.to_i, stroke: txtclr)
  end
  
  def clear_text
    @timer.stop if @timer
    @box.hover{}
    @box.leave{}
  end
  
end
