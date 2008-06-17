class Armor < Item
	include Term::ANSIColor
	attr_reader(:type)

	def initialize(name, short_desc, description, damage_bonus, armor_bonus, weight, value, type)
		super(name, short_desc, description, damage_bonus, armor_bonus, weight, value)
		@type = type
	end
	
	def inventory_name
		return @name.green
	end
end