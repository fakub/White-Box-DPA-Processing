def alt_mask(settings)
	puts "\nCreating filter mask ..."

	filter_files = Dir["#{TRACES_DIR}/#{settings[:name]}/*"].first N_FOR_FILTER
	ref = File.read(filter_files.slice!(0)).unpack("C*")
	alt = [false] * ref.length

	filter_files.each do |file|
		alt = File.read(file).unpack("C*").zip(ref, alt).map{|x,r,a| a or x != r}
	end
	return alt
end