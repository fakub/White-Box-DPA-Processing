def get_bin_traces(settings, merge)
	if merge
		FileUtils.mv settings.path, settings.path__bkp
	end
	
	FileUtils.mkpath(settings.bin_traces_dir)
	prng = Random.new
	
	puts "\nAcquiring traces ..."
	puts "_" * settings.n_dots
	doti = 0
	
	pt = nil   # s.t. it persists outside the block
	
	# acquire binary traces
	settings[:n_traces].times do |i|
		if i*settings.n_dots >= settings[:n_traces]*doti; doti += 1; print "."; end   # progress bar
		
		pt = prng.bytes(16).unpack("H*").first
		ct = Open3.capture2([settings.acq[:bin], settings[:cmd], pt].join(" "))[0].split(/\n/)[settings[:ct_row]-1].gsub(/\s+/, "")
		
		$stderr.puts("
Running `#{[settings.acq[:bin], settings[:cmd], pt].join(" ")}` but no result found.

PIN probably cannot instrument program due to certain OS limitations. Consider
	$ sudo echo 0 > /proc/sys/kernel/yama/ptrace_scope

") or exit unless File.exists? settings.acq[:trace_filename][:bin]
		$stderr.puts("Incorrect output format, consider changing ct_row parameter.") or exit unless !ct[/\H/] and ct.length == 32
		
		FileUtils.mv settings.acq[:trace_filename][:bin], "#{settings.bin_traces_dir}/#{pt}_#{ct}"
	end
	puts
	settings[:sample_pt] = pt
	
	alt = alt_mask(settings.bin_traces_dir)
	filter(Dir["#{settings.bin_traces_dir}/*"], alt, :bin, true)
	mask_to_file(alt, settings.const_filter_file)
end

def get_txt_trace(settings)
	Open3.capture2([settings.acq[:txt], settings[:cmd], settings[:sample_pt]].join(" "))
	
	filter([settings.acq[:trace_filename][:txt]], mask_from_file(settings.const_filter_file), :txt)
	FileUtils.mv settings.acq[:trace_filename][:txt], "#{settings.traces_dir}/#{settings[:sample_pt]}"
	FileUtils.mv settings.acq[:trace_filename][:txt] + ".flt", settings.txt_trace
end