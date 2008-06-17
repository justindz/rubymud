class Character < Actor
	attr_accessor(:client)
	
	def initialize(name)
		super(name)
		@region = @area = 0
		prepare
	end
	
	def to_yaml_properties
		%w{ @name @str @will @dex @hp @focus @actions @points @coins @region @area @items @equipment @damage_bonus @armor_bonus }
	end
	
	def prepare
		@hp = @str
		@focus = @will
		@actions = @dex / 10
		@burden = 0
		@beat_count = 0
		items.each_value do |i|
			@burden += i.weight
		end
	end
	
	def description
		"Looks to be in #{health} condition w/ #{@coins} coins in the pocket."
	end
	
	def health
		if @hp / @str >= 0.9
			":-)".green
		elsif @hp / @str >= 0.7
			":-|".green
		elsif @hp / @str >= 0.5
			":-/".yellow
		elsif @hp / @str >= 0.3
			":-{".red
		else
			"X-P".red
		end
	end
	
	def pickup(item)
		if @burden + item.weight <= @str
			@burden += item.weight
			@client.add_observer(item)
			@items[item.object_id] = item
			return true
		else
			return false
		end
	end
	
	def drop(item)
		if item.cursed?
			return false
		else
			@burden -= item.weight
			@client.delete_observer(item)
			@items.delete(item.object_id)
			return true
		end
	end
	
	def wield(item)
		return false unless item.type == :wield
		if @equipment[:wield].nil? #modify so that weapons will automatically unwield when you wield something else
			#test to see if character can wield
			@equipment[:wield] = item
			@damage_bonus += item.damage_bonus
			@items.delete(item.object_id)
			return true
		else
			return false
		end
	end
	
	def unwield(item)
		@items[item.object_id] = item
		@equipment.delete(:wield)
		@damage_bonus -= item.damage_bonus
		return true
	end
	
	def destroy(item)
		if item.cursed? || item.indestructible?
			return false
		else
			@burden -= item.weight
			@client.delete_observer(item)
			@items.delete(item.object_id)
			return true
		end
	end
end