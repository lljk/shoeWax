require 'green_shoes'
require 'observer'
require './helper_methods.rb'
require './browser.rb'

Shoes.app do
	
	def update(message)
		p message
	end
	
	db = dir_browser("/home/jk/tunes")
	db.add_observer(self)
end
