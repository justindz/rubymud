module Responder
	def update(event, args)
		begin
			self.send("event_" + event.to_s, args)
		rescue NoMethodError
			#puts "#{self.class} received an event: #{event.to_s} w/ args: #{args.to_s} that it did not understand."
		end
	end
end