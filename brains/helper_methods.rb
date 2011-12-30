class String

	def esc_html
		return self.gsub(
		'&', '&amp;'
		).gsub(
		'<', '&lt;'
		)
	end
	
end