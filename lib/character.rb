require 'lib/actor'

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
		items.each do |i|
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
			@items.push(item)
			return true
		else
			return false
		end
	end
	
	def drop(i)
	  item = item(i)
	  return false if item.nil?
		if item.cursed?
			return false
		else
			@burden -= item.weight
			@client.delete_observer(item)
			@items.delete_at(i)
			return true
		end
	end
	
	def wield(i)
	  if item = item(i)
		  return false unless item.type == :wield
		  if @equipment[:wield].nil? #modify so that weapons will automatically unwield when you wield something else
			  #test to see if character can wield
			  @equipment[:wield] = item
			  @damage_bonus += item.damage_bonus #refactor
			  @armor_bonus += item.armor_bonus #refactor
			  @items.delete_at(i)
			  return true
		  else
			  return false
		  end
		else
		  return false
		end
	end
	
	def unwield(item)
	  unless @equipment[:wield].nil?
  		@items.push(item)
	  	@equipment.delete(:wield)
	  	@damage_bonus -= item.damage_bonus
	  	@armor_bonus -= item.armor_bonus
	  	return true
	  else
	    return false
	  end
	end
	
	def wear(i)
	  if item = item(i)
	    return false unless item.class == Armor.class
	    if @equipment[item.type].nil?
	      @equipment[item.type] = item
	      @damage_bonus += item.damage_bonus #refactor
	      @armor_bonus += item.armor_bonus #refactor
	      @items.delete_at(i)
	      return true
	    else
	      return false
	    end
	  end
	end
	
	def remove(type)
	  item = @equipment[type]
	  unless item.nil?
	    @items.push(item)
	    @equipment.delete(type)
	    @damage_bonus -= item.damage_bonus
	    @armor_bonus -= item.armor_bonus
	    return true
    else
      return false
    end
	end
	
	def destroy(i)
	  item = item(i)
		if item.nil? || item.cursed? || item.indestructible?
			return false
		else
			@burden -= item.weight
			@client.delete_observer(item)
			@items.delete_at(i)
			return true
		end
	end
end
