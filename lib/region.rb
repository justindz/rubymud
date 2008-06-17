class Region
	attr_accessor(:num, :name, :areas)
	
	def initialize(num, name)
		@num = num
		@name = name
		@areas = Hash.new
	end
end