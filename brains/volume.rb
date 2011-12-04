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

		bg = image imagedir + "vol.png"
	
		@slider = image imagedir + "volslider.png"
		@slider.move((9.0 * @scale).round, self.top)
	
		@slider.click{motion{|x, y| slide(y)}}
		@slider.release{motion{}}
		
	end
	
	def slide(y)
		y = self.top if y < self.top
		y = self.top + (160 * @scale).round if y > self.top + (160 * @scale).round
		pos = y - self.top
		@slider.move((9.0 * @scale).round, pos)
		
		setvol(@slider.top)
	end
	
	def setvol(pos)
		vol = (((pos - (160.0 * @scale)) * 1.25) * -1.0) / 100.0
		@pipeline.volume = vol.round(1)
	end
	
end