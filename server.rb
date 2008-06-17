require 'yaml'
require 'socket'
require 'observer'
require 'thread'
require 'rubygems'
require_gem 'term-ansicolor'

require 'lib/responder'
require 'lib/item'
require 'lib/weapon'
require 'lib/armor'
require 'lib/actor'
require 'lib/player'
require 'lib/character'
require 'lib/client'
require 'lib/command'
require 'lib/npc'
require 'lib/world'
require 'lib/region'
require 'lib/area'
require 'lib/heart'
require 'lib/fight'
#require Treasure Generator

class String
	include Term::ANSIColor
end

puts "Loading configuration..."
config = YAML.load_file("config/config.yaml")
Thread.abort_on_exception = config['debug']

puts "Loading regions..."
regions = Hash.new
Dir.foreach("regions") do |f|
	if f != "." && f != ".." && f != ".svn"
		region = YAML.load_file("regions/#{f}")
		region.areas.each do |a|
			a.region = region
			a.npcs = Hash.new #refactor
			a.items = Hash.new #refactor
		end
		regions[region.num] = region
	end
end

puts "Loading world..."
world = World.new(config['world']['name'], config['world']['description'], regions)

puts "Starting the heart..."
Thread.new {
	h = Heart.new
	world.heart = h
	h.start
}

# put test stuff in the builder script

#test npc
a = regions[0].areas[0]
fido = NPC.new('fido', 'A small dog.', regions[0], regions[0].areas[0])
a.add_observer(fido)
fido.add_observer(a)
world.heart.add_observer(fido)
a.npcs[fido.object_id] = fido
#/test

#test items
knife = Weapon.new('knife', 'a small knife is balancing here on its point', 'LONG DESCRIPTION', 1, 0, 1, 2, 1, 4)
knife.indestructible
world.heart.add_observer(knife)
a.items[knife.object_id] = knife

pants = Armor.new('pants', 'some really swank pants', 'LONGER DESCRIPTION', 0, 2, 3, 2, :legs)
world.heart.add_observer(pants)
a.items[pants.object_id] = pants
#/test

puts "Starting the server..."
server = TCPServer.new(config['port'])
threads = []

while (session = server.accept)
	#log connection and address
	threads << Thread.new(session) { |s|
		if threads.length < config['max_connections']
			puts "Accepting connection from #{s.addr[2]}."
			c = Client.new(s, world, config)
			Thread.current['client'] = c
			c.start
		else
			puts "Rejecting connection: full."
			s.puts "Sorry, we're full right now."
			s.close
		end
	}
end