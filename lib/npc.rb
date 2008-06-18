class NPC < Actor
	attr_accessor(:description, :fighting, :target)
	attr_reader(:wield)
	
	def initialize(name, description, region, area)
		super(name)
		@description = description
		@actions = @points = 1
		@region = region
		@area = area
		@fighting = false
		@target = nil
		@wield = nil
	end
	
	# EVENT HANDLERS
	
	def event_beat(args)
		@beat_count += 1
		if @beat_count % 8 == 0 && !@fighting
			@area.characters.each do |c|
				changed
				notify_observers(:say, [self,"Hi, #{c[1].name}."])
			end
		end
		if @beat_count > 20
			@beat_count = 0
			regen
		end
		#do I want to attack someone?
		#do I want to follow someone?
		#is it time to regenerate?
		#is it time to go somewhere?
	end

	def event_say(args) #args == [Character|NPC,String]
		if @beat_count % 5 == 0 && args[0] != self && !@fighting
			changed
			notify_observers(:say, [self,"Interesting observation, #{args[0].name}"])
		end
	end
	
	#def event_dropped(args) #args == Character|Item
	
	def event_attack(args)
		@actions.times do
			changed
			notify_observers(:swing, [self,@target])
		end
	end
	
	def event_hit(args) #args == [Client|NPC,Client|NPC,Fixnum]
		if args[1] == self
			#take the damage in args[2]
			@target = args[0]
		end
	end
	
	def event_miss(args) #args == [Client|NPC,Client|NPC]
		if args[1] == self && @target.nil?
			@target = args[0]
		end
	end
end
