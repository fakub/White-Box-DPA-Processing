def alt_mask(dirname)
	filter_files = Dir["#{dirname}/*"].first GS[:n_for_filter]
	ref = File.read(filter_files.slice!(0)).unpack("C*")
	alt = [false] * ref.length
	
	puts "\nCreating filter mask ..."
	puts "_" * filter_files.size
	
	filter_files.each do |file|
		print "."
		alt = File.read(file).unpack("C*").zip(ref, alt).map{|x,r,a| a or x != r}
	end
	puts
	
	return alt
end