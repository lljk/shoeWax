class VolumeBar < Shoes::Widget
  
  def initialize(pipeline = nil, scale)
    @pipeline = pipeline
    @scale = scale
    
    case scale
      when 1.0
        dir = "100%"
      when 0.5
        dir = "50%"
      when 0.35
        dir = "35%"
    end
  
    homedir = File.dirname(File.expand_path(__FILE__))
    imagedir = homedir + "/images/#{dir}/"

    @vol_bg = image imagedir + "vol.png"
  
    @slider = image imagedir + "volslider.png"
    @slider.move((9.0 * @scale).round, 0)
  
    @slider.click{@flag = true}
    @slider.release{@flag = false}
    motion{|x, y| slide(y) if @flag}
  end
  
  def slide(y)
    dh = @slider.height/2
    y = @vol_y + dh/2 if y < @vol_y + dh/2
    y = @vol_y + (160 * @scale).round + dh*2 if y > @vol_y + (160 * @scale).round + dh*2
    @slider.move(@vol_x, y-dh)
    setvol(y-dh)
  end
  
  def setvol(pos)
    vol = (pos - 160 * @scale) / 100.0
    @pipeline.volume = vol.round(1)
  end
  
  def move x, y
    @vol_x, @vol_y = x, y
    @vol_bg.move x, y
    @slider.move x, y
  end
  
end
