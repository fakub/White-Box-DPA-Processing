# create binary mask for GS[:n_for_filter] traces from given directory
# 1 <=> given bit alternates across traces

def alt_mask(dirname)
	# get a list of traces
	filter_files = Dir["#{dirname}/*"].first GS[:n_for_filter]
	# read reference trace
	ref = File.read(filter_files.slice!(0)).unpack("C*")
	# init mask
	alt = [false] * ref.length
	
	puts "\nCreating filter mask ..."
	puts "_" * filter_files.size
	
	# for each trace, put 1 where given bit differs
	filter_files.each do |file|
		print "."
		alt = File.read(file).unpack("C*").zip(ref, alt).map{|x,r,a| a or x != r}
	end
	puts
	
	return alt
end