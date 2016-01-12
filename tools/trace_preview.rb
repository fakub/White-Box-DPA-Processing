def trace_preview(settings, sample_pt, alt)
	puts "\nCreating trace previews ..."
	
	Open3.capture2([settings[:acq][:txt], settings[:cmd], sample_pt].join(" "))
	filter([TRACE_FILENAME[:txt]], alt, :txt)
	FileUtils.mv TRACE_FILENAME[:txt], "#{VISUAL_DIR}/#{settings[:name]}_#{sample_pt}.orig"
	FileUtils.mv TRACE_FILENAME[:txt] + ".flt", "#{VISUAL_DIR}/#{settings[:name]}_#{sample_pt}.flt"
	
	addr_from = 0   # either none or both must be set
	addr_to = 0xffffffffffff
	
	line_from = 0
	line_to = Float::INFINITY
	
	#~ split_files = 1
	
	ff = gen_view("#{VISUAL_DIR}/#{settings[:name]}_#{sample_pt}.flt", addr_from, addr_to, line_from, line_to, 1, nil, nil)
	fo = gen_view("#{VISUAL_DIR}/#{settings[:name]}_#{sample_pt}.orig", addr_from, addr_to, line_from, line_to, 1, nil, nil)
	
	return [ff.first, fo.first]
end