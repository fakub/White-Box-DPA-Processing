def group_of_target(target_str, type = nil)
	return target_str, 1 if type.nil?
	
	target = target_str.to_i(2)
	return "%04b" % [(target & 0xf0) >> 4], 16 if type == :xf0
	return "%04b" % [(target & 0x0f)], 16 if type == :x0f
	
	if type == :p
		target_str = target_str[2..-1]
		puts "Got #{target_str}"
		repre = [0xff, 0x0d, 0x01, 0x05, 0x09, 0x1d, 0x11, 0x15, 0x19, 0x2d, 0x25, 0x3b, 0x3f, 0x35, 0x5b, 0x55, 0x6f, 0x77, 0x0b, 0x0f, 0x03, 0x07, 0x1b, 0x1f, 0x13, 0x17, 0x2b, 0x2f, 0x27, 0x3d, 0x33, 0x37, 0x5f, 0x57, 0x7f].map{|r|"%08b" % [r]}
		8.times do |rot|
			rottrg = (target_str * 2)[rot..(7+rot)]
			puts "Trying #{rottrg}"
			if repre.include? rottrg
				ts = 8
				ts = 4 if [0x11, 0x33, 0x77].include? rottrg.to_i(2)
				ts = 2 if [0x55].include? rottrg.to_i(2)
				ts = 1 if [0xff].include? rottrg.to_i(2)
				return "%s%02x" % [rottrg.scan("1").size & 1 == 0 ? "n_" : "i_", rottrg.to_i(2)], ts
			end
		end
		raise "No representant for #{target_str}!"
	end
	
	return nil, nil
end