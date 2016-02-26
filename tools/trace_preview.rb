def trace_preview(settings, sample_pt, alt)
	FileUtils.rm_rf("#{settings.visual_dir}", secure: true)
	FileUtils.mkpath("#{settings.visual_dir}")
	
	Open3.capture2([settings.acq[:txt], settings[:cmd], sample_pt].join(" "))
	filter([settings.acq[:trace_filename][:txt]], alt, :txt)
	FileUtils.mv settings.acq[:trace_filename][:txt], "#{settings.visual_dir}/#{sample_pt}"
	FileUtils.mv settings.acq[:trace_filename][:txt] + ".flt", "#{settings.visual_dir}/#{sample_pt}.flt"
	
	addr_from = 0   # either none or both must be set
	addr_to = 0xffffffffffff
	
	line_from = 0
	line_to = Float::INFINITY
	
	#~ split_files = 1
	
	return gen_view("#{settings.visual_dir}/#{sample_pt}.flt", addr_from, addr_to, line_from, line_to, 1, nil, nil).first
end