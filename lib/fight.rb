class Fight
	include Observable
	include Responder
	include Term::ANSIColor
	attr_accessor(:fighters)
	attr_reader(:world, :area)
	
	def initialize(world)
		@world = world
		@world.heart.add_observer(self)
		@area = nil
		@fighters = Hash.new
		@fighting = true
		
		@hitrate_modifiers = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45]
	end
	
	def add_fighter(fighter)
		fighter.fighting = true
		@fighters[fighter.object_id] = fighter
		fighter.add_observer(self)
	end
	
	def remove_fighter(fighter)
		fighter.fighting = false
		@fighters.delete(fighter.object_id)
		fighter.remove_observer(self)
	end
	
	def finish
		@fighters.each do |f|
			remove_fighter(f)
		end
		remove_observer(@area)
		@world.heart.remove_observer(self)
	end
	
	def start(aggressor, victim)
		aggressor.target = victim
		victim.target = aggressor
		@area = aggressor.area
		add_observer(@area)
		add_fighter(aggressor)
		add_fighter(victim)
		event_swing([aggressor,victim])
		while @fighting
			break if @fighters.empty?
		end
		finish
	end
	
	def hits(aggressor, victim)
		diff = aggressor.dex - victim.dex
		if diff.abs > 9
			modifier = @hitrate_modifiers[9]
		else
			modifier = @hitrate_modifiers[diff.abs]
		end
		if diff < 0
			modifier = -modifier
		end
		chance = 50 + modifier
		return (rand(100) + 1) <= chance
	end
	
	def calc_damage(aggressor, victim)
		if rand(100) < 5 #critical hit!
			reduction = 0
		else
			reduction = victim.reduction
		end
		return aggressor.damage - reduction
	end
	
	# EVENT HANDLERS

	def event_beat(args)
		changed
		notify_observers(:attack, nil)
	end
	
	def event_swing(args) #args == [Client|NPC,Client|NPC]
		changed
		if hits(args[0], args[1])
			# add a dodge
			args << calc_damage(args[0], args[1])
			notify_observers(:hit, args)
		else
			notify_observers(:miss, args)
		end
	end
end