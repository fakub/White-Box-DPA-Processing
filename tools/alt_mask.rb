def alt_mask(settings)
	puts "\nCreating filter mask ..."
	
	filter_files = Dir["#{GS[:traces_dir]}/#{settings[:name]}/*"].first GS[:n_for_filter]
	ref = File.read(filter_files.slice!(0)).unpack("C*")
	alt = [false] * ref.length
	
	filter_files.each do |file|
		alt = File.read(file).unpack("C*").zip(ref, alt).map{|x,r,a| a or x != r}
	end
	return alt
end