require 'digest/sha1'

class Player
	attr_accessor(:username, :password, :characters)
	
	def initialize(username, password)
		@username = username
		@password = Digest::SHA1.hexdigest(password)
		@characters = Hash.new
	end
	
	def password=(new_password)
		@password = Digest::SHA1.hexdigest(new_password)
	end
end