class Item
	include Observable
	include Responder
	include Term::ANSIColor
	
	attr_accessor(:name, :short_desc, :description, :damage_bonus, :armor_bonus, :weight, :value, :flags)
	
	def initialize(name, short_desc, description, damage_bonus, armor_bonus, weight, value)
		@name = name
		@short_desc = short_desc
		@description = description
		@damage_bonus = damage_bonus
		@weight = weight
		@value = value
		@flags = Array.new
	end
	
	def type
		return :item
	end
	
	def inventory_name
		return @name
	end
	
	def cursed
		@flags << :cursed unless @flags.include?(:cursed)
	end
	
	def cursed?
		return true if @flags.include?(:cursed)
	end
	
	def indestructible
		@flags << :indestructible unless @flags.include?(:indestructible)
	end
	
	def indestructible?
		return true if @flags.include?(:indestructible)
	end
	
	# EVENT HANDLERS
	
	def event_beat(args)
		# make sure we don't have to expire a spell, etc.
	end
	
	def event_picked(args) #args=[Client|NPC,Item]
		# activate a spell, etc.
	end
	
	def event_dropped(args) #args=[Client|NPC,Item]
		#possible removal of spell effects, etc.
	end
	
	def event_destroyed(args) #args=[Client|NPC,Item]
		#possible removal of spell effects, etc.
	end
end
