def trace_preview(settings, sample_pt, alt)
	FileUtils.rm_rf("#{GS[:visual_dir]}/#{settings[:name]}", secure: true)
	FileUtils.mkpath("#{GS[:visual_dir]}/#{settings[:name]}")
	
	Open3.capture2([settings[:acq][:txt], settings[:cmd], sample_pt].join(" "))
	filter([GS[:trace_filename][:txt]], alt, :txt)
	FileUtils.rm GS[:trace_filename][:txt]
	FileUtils.mv GS[:trace_filename][:txt] + ".flt", "#{GS[:visual_dir]}/#{settings[:name]}/#{sample_pt}.flt"
	
	addr_from = 0   # either none or both must be set
	addr_to = 0xffffffffffff
	
	line_from = 0
	line_to = Float::INFINITY
	
	#~ split_files = 1
	
	return gen_view("#{GS[:visual_dir]}/#{settings[:name]}/#{sample_pt}.flt", addr_from, addr_to, line_from, line_to, 1, nil, nil).first
end