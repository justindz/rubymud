class World
	attr_accessor(:name, :description, :regions, :players, :heart)
	
	def initialize(name, description, regions)
		@name = name
		@description = description
		@regions = regions
		@players = Hash.new
	end
end