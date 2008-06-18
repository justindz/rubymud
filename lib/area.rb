class Area
	include Observable
	include Responder
	include Term::ANSIColor
	attr_accessor(:region, :num, :name, :description, :exits, :characters, :npcs, :items)
	
	def initialize(region, num, name, description)
		@region = region
		@num = num
		@name = name
		@description = description
		@exits = Hash.new
		@characters = Hash.new #make sure this is empty when saving an area in online creation
		@npcs = Hash.new
		@items = Hash.new
	end
	
	def north=(exit)
		@exits['north'] = exit
	end
	
	def south=(exit)
		@exits['south'] = exit
	end
	
	def east=(exit)
		@exits['east'] = exit
	end
	
	def west=(exit)
		@exits['west'] = exit
	end
	
	def up=(exit)
		@exits['up'] = exit
	end
	
	def down=(exit)
		@exits['down'] = exit
	end
	
	def view(character)
		"#{@name}\n\n#{@description}\n\nExits: #{exit_list}\n#{character_list(character)}\n#{npc_list}\n#{item_list}\n"
	end
	
	def has_item?(name)
		items.each_value do |i|
			return true if i.name == name
		end
		return false
	end
	
	def item(name)
		items.each_value do |i|
			return i if i.name == name
		end
		return nil
	end
	
	def has_npc?(name)
		npcs.each_value do |n|
			return true if n.name == name
		end
		return false
	end
	
	def npc(name)
		npcs.each_value do |n|
			return n if n.name == name
		end
		return nil
	end
	
	def exit_list
		list = ""
		if !@exits.nil?
			@exits.each_key do |key|
				list += "#{key}\n"
			end
		end
		return list
	end
	
	def character_list(character)
		list = ""
		@characters.each_value do |c|
			list += "#{c.name} is here\n" unless c == character
		end
		return list
	end
	
	def npc_list
		list = ""
		if !@npcs.nil?
			@npcs.each_value do |n|
				list += "#{n.name} is here\n"
			end
		end
		return list
	end
	
	def item_list
		list = ""
		if !@items.nil?
			@items.each_value do |i|
				list += "#{i.short_desc}\n"
			end
		end
		return list
	end
	
	# EVENT HANDLERS
	
	def event_say(args) #args == [Character|NPC,String]
		changed
		notify_observers(:say, args)
	end
	
	def event_quit(args) #args == [Character]
	  changed
	  notify_observers(:quit, args)
	  @characters.delete(args.name)
		delete_observer(args.client)
		args.client.delete_observer(self)
	end
	
	def event_go(args) #args == [Character|NPC,Area]
		case args[0]
		when Character
			args[0].client.changed
			args[0].client.notify_observers(:left, args[0])
			args[0].area = args[1]
			args[0].client.add_observer(args[1])
			args[1].add_observer(args[0].client)
			args[0].client.changed
			args[0].client.notify_observers(:arrived, args[0])
		when NPC
			args[0].changed
			args[0].notify_observers(:left, args[0])
			args[0].area = args[1]
			args[0].add_observer(args[1])
			args[1].add_observer(args[0])
			args[0].changed
			args[0].notify_observers(:arrived, args[0])
		end
	end
	
	def event_arrived(args) #args == Character|NPC
		case args
		when Character
			@characters[args.name] = args
		when NPC
			@npcs[args.name] = args
		end
		changed
		notify_observers(:arrived, args)
	end
	
	def event_left(args) #args == Character|NPC
		case args
		when Character
			@characters.delete(args.name)
			delete_observer(args.client)
			args.client.delete_observer(self)
		when NPC
			@npcs.delete(args.name)
			delete_observer(args)
			args.delete_observer(self)
		end
		changed
		notify_observers(:left, args)
	end
	
	def event_dropped(args) #args == [Character,Item]
		items[args[1].object_id] = args[1]
		changed
		notify_observers(:dropped, args)
	end
	
	def event_picked(args) #args == [Character,Item]
		@items.delete(args[1].object_id)
		changed
		notify_observers(:picked, args)
	end
	
	def event_wield(args) #args == [Character,Item]
		changed
		notify_observers(:wield, args)
	end
	
	def event_unwield(args) #args == [Characer,Item]
		changed
		notify_observers(:unwield, args)
	end
	
	def event_destroyed(args) #args == Character|Item
		#do something if a user destroys a power unleashing item
		changed
		notify_observers(:destroyed, args)
	end
	
	def event_attack(args)
		changed
		notify_observers(:attack, args)
	end
	
	def event_hit(args) #args == [Client|NPC,Client|NPC,Fixnum]
		changed
		notify_observers(:hit, args)
	end
	
	def event_miss(args) #args == [Client|NPC,Client|NPC]
		changed
		notify_observers(:miss, args)
	end
end
