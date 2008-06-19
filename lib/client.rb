require 'digest/sha1'

class Client
	include Observable
	include Responder
	include Term::ANSIColor
	attr_accessor(:fighting, :cooldown, :action_queue, :target)
	attr_reader(:world, :c, :s, :beat_count)
	
	def initialize(session, world, config)
		@s = session
		@world = world
		@config = config
		@cooldown = 0
		@action_queue = Queue.new
		@target = nil
		@fighting = false
	end
	
	def cool
		@cooldown -= 1 if @cooldown > 0
	end
	
	def prompt
		@s.print "#{@c.hp}h".green + " " + "#{@c.focus}f".blue + "> "
	end
	
	def save
		@c.region = @c.region.num
		@c.area = @c.area.num
		@player.characters[@c.name] = @c
		File.open("players/#{@player.username}.yaml", "w") { |f| f.puts YAML.dump(@player) } #error handling needed
	end
	
	def login
		@s.puts @config['messages']['login']
		loop do
			@s.print @config['messages']['username_prompt'] + " "
			username = @s.gets.chomp! #issue here with funky leading characters, regex clean?
			@s.print @config['messages']['password_prompt'] + " "
			password = @s.gets.chomp!
			@player = YAML.load_file("players/#{username}.yaml") #error handling needed
			if (@player != nil) && (Digest::SHA1.hexdigest(password) == @player.password) && (@world.players[@player.username] != true)
				@world.players[@player.username] = true
				@player.characters.each_with_index do |c, i|
					@s.puts "#{i} - #{c[1].name}"
				end
				@s.print @config['messages']['character_prompt'] + " "
				choice = @s.gets.to_i
				@c = @player.characters.to_a[choice][1]
				break
			else
				@s.puts @config['messages']['login_retry']
			end
		end
		@c.prepare
		@s.puts "Logged in to #{@world.name} as #{@c.name}.\n\n"
		@c.client = self
		@c.region = @world.regions[@c.region]
		@c.area = @c.region.areas[@c.area]
		@c.area.add_observer(self)
		self.add_observer(@c.area)
		changed
		notify_observers(:arrived, @c)
		@world.heart.add_observer(self)
	end
	
	def start
		login
		command = Command.new(@c, @s, self)
		while command.online
		  begin
			  prompt
			  args = @s.gets.chomp!.split
			rescue NoMethodError
			  disconnect(command)
			  return false
			end
			methd = args[0]
			args.delete_at(0)
			begin
				if !methd.nil?
					if fighting
						if command.fight_commands.include?(methd)
							command.send(methd, args)
						else
							@s.puts "Not while you're fighting."
						end
					else
						command.send(methd, args)
					end
				end
			rescue NoMethodError => e
				@s.puts "I don't recognize that command."
				puts "NoMethodError for #{methd} using '#{args}': #{e}."
			rescue ArgumentError => e
			  @s.puts "The arguments you've supplied are incorrect."
			  puts "ArgumentError for #{methd} using '#{args}'."
			  args.each do |arg|
			    puts arg.class
			  end
			rescue TypeError
				puts "TypeError for #{methd} : #{args} in client."
			end
		end
		disconnect(command)
	end
	
	def disconnect(command)
	  save
	  changed
		notify_observers(:quit, @c)
		command.send("quit", "disconnected")
		@world.players[@player.username] = false
	  unless @s.closed?
  	  @s.close
  	end
		puts "#{@player.username} disconnected."
		return true
	end
	
	# DELEGATES TO CHARACTER
	
	def name
		@c.name
	end
	
	def str
		@c.str
	end

	def dex
		@c.dex
	end
	
	def coins
		@c.coins
	end
	
	def area
		@c.area
	end
	
	def damage
		@c.damage
	end
	
	def reduction
		@c.reduction
	end
	
	# EVENT HANDLERS
		
	def event_beat(args)
		@c.beat_count += 1
		if @c.beat_count > 20
			@c.beat_count = 0
			@c.regen
		end
		if @action_queue.size > 0 && @fighting
			action = @action_queue.deq
			@s.puts "You #{action}." # Do something with me
		end
		cool
	end
	
	def event_say(args) #args == [Character|NPC,String]
		if args[0] == @c
			@s.puts "You say \"#{args[1]}\""
		else
			@s.puts "#{args[0].name} says \"#{args[1]}\""
		end
	end
	
	def event_arrived(args) #args == Character|NPC
		if args == @c
			@s.puts @c.area.view(@c)
		else
			@s.puts "#{args.name} arrived."
		end
	end
	
	def event_left(args) #args == Character|NPC
		begin
			if args != @c
				@s.puts "#{args.name} left."
			end
		rescue IOError
			puts "IOError in the :left message to the Client with args: #{args}"
		end
	end
	
	def event_dropped(args) #args == Character|Item
		if args[0] == @c
			@s.puts "You drop a #{args[1].name}."
		else
			@s.puts "#{args[0].name} drops a #{args[1].name}."
		end
	end
	
	def event_picked(args) #args == Character|Item
		if args[0] == @c
			@s.puts "You pick up a #{args[1].name}."
		else
			@s.puts "#{args[0].name} picks up a #{args[1].name}."
		end
	end
	
	def event_wield(args) #args == [Character,Item]
		if args[0] == @c
			@s.puts "You wield the #{args[1].name}."
		else
			@s.puts "#{args[0].name} wields a #{args[1].name}."
		end
	end
	
	def event_unwield(args) #args == [Character,Item]
		if args[0] == @c
			@s.puts "You unwield the #{args[1].name}."
		else
			@s.puts "#{args[0].name} stops wielding a #{args[1].name}."
		end
	end
	
	def event_destroyed(args) #args == Character|Item
		if args[0] == @c
			@s.puts "You destroy your #{args[1].name}."
		end
	end
	
	def event_attack(args)
		@c.actions.times do
			if @action_queue.size > 0
				action = @action_queue.deq
				# spells require available focus and increase cooldown
				# skills increase cooldown
				# test code
				@s.puts "Instead of attacking, I'm doing #{action}."
				# /test code
			else
				changed
				notify_observers(:swing, [self,@target])
			end
		end
		cool
	end
	
	def event_hit(args) #args == [Client|NPC,Client|NPC,Fixnum]
		
		if args[0] == self
			@s.puts "You hit #{args[1].name} for #{args[2]} damage."
		elsif args[1] == self
			# take the damage in args[2]
			@s.puts "#{args[0].name} hits you for #{args[2]} damage."
		else
			@s.puts "#{args[0].name} hits #{args[1].name}."
		end
	end
	
	def event_miss(args) #args == [Client|NPC,Client|NPC]
		if args[0] == self
			@s.puts "You miss a swing at #{args[1].name}."
		elsif args[1] == self
			@s.puts "#{args[0].name} misses a swing at you."
		else
			@s.puts "#{args[0].name} misses a swing at #{args[1].name}."
		end
	end
end
