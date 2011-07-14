require 'yaml'
require 'observer'
require 'rubygems'
require 'term/ansicolor'

require 'lib/responder'
require 'lib/item'
require 'lib/player'
require 'lib/character'
require 'lib/client'
require 'lib/world'
require 'lib/region'
require 'lib/area'

region = Region.new(0, 'Town')

area = Area.new(0, 0, 'Library', 'Busy as a bee.')
area2 = Area.new(0, 1, 'Wall', 'Hippies abound.')
area.east = area2.num
area2.west = area.num

region.areas[area.num] = area
region.areas[area2.num] = area2

player = Player.new('justindz', '********')

character = Character.new('God')
character2 = Character.new('Dog')

player.characters[character.name] = character
player.characters[character2.name] = character2

puts region.to_yaml
puts "\n\n\n"
puts player.to_yaml
