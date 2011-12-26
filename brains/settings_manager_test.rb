require 'green_shoes'
require 'observer'
require './settings_manager.rb'


Shoes.app do
	
	Shoes::App.class_eval{include Observable}
	
	def update(message)
		p message
	end
	
	sm = settings_manager
	
	sm.add_observer(self)
	
end
