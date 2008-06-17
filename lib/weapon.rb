class Weapon < Item
	include Term::ANSIColor
	attr_reader(:type, :dice_count, :damage_dice)

	def initialize(name, short_desc, description, damage_bonus, armor_bonus, weight, value, dice_count, damage_dice)
		super(name, short_desc, description, damage_bonus, armor_bonus, weight, value)
		@dice_count = dice_count
		@damage_dice = damage_dice
	end
	
	def type
		return :wield
	end
	
	def inventory_name
		return @name.red
	end
	
	def damage
		total = 0
		@dice_count.times do
			total += rand(@damage_dice) + 1
		end
		return total
	end
end