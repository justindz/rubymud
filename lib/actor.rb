class Actor
	include Observable
	include Responder
	attr_accessor(:str, :will, :dex, :hp, :focus, :actions, :points, :coins, :region, :area, :items, :equipment, :damage_bonus, :armor_bonus)
	attr_reader(:name, :points, :burden, :beat_count)
	
	def initialize(name)
		@name = name
		@str = @will = @dex = @hp = @focus = 10
		@damage_bonus = @armor_bonus = 0
		@points = @burden = 0
		@coins = 3
		@items = []
		@equipment = Hash.new
		@beat_count = 0
	end
	
	def regen
		@hp += @hp / 10 unless @hp >= @str
	end
	
	def damage
		base = 0
		if @equipment[:wield].nil?
			base = rand(@str / 10) + 1
		else
			base = @equipment[:wield].damage
		end
		return base + (@str / 5) + @damage_bonus
	end
	
	def reduction
		(@dex / 5) + @armor_bonus
	end
	
	def has_item?(name)
		@items.each do |i|
			return true if i.name == name
		end
		return false
	end
	
	def wield_item?(name)
		if @equipment[:wield].name == name
			return true
		else
			return false
		end
	end
	
	def item(i)
	  return false if i < 0
		i >= @items.size ? false : @items[i]
	end
end
