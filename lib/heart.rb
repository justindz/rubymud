class Heart
	include Observable
	
	def initialize
	end
	
	def start
		loop do
			changed
			notify_observers(:beat, nil)
			sleep(5)
		end
	end
end