# defines method for acquiring both binary and text traces

def get_bin_traces(settings, merge)
	# if name exists, user might want to merge new traces with existing
	if merge
		# move to backup location
		FileUtils.mv settings.path, settings.path__bkp
	end
	
	# prepare traces' directory
	FileUtils.mkpath(settings.bin_traces_dir)
	# init randomness
	prng = Random.new
	
	puts "\nAcquiring traces ..."
	puts "_" * settings.n_dots
	doti = 0
	
	pt = nil   # variable survives outside the block
	
	# acquire given amount of binary traces
	settings[:n_traces].times do |i|
		if i*settings.n_dots >= settings[:n_traces]*doti; doti += 1; print "."; end   # progress bar
		
		# get random plaintext
		pt = prng.bytes(16).unpack("H*").first
		# acquire single binary trace & get resulting ciphertext
		ct = Open3.capture2([settings.acq[:bin], settings[:cmd], pt].join(" "))[0].split(/\n/)[settings[:ct_row]-1].gsub(/\s+/, "")
		
		$stderr.puts("
Running `#{[settings.acq[:bin], settings[:cmd], pt].join(" ")}` but no result found.

PIN probably cannot instrument program due to certain OS limitations. Consider
	$ sudo su
	$ echo 0 > /proc/sys/kernel/yama/ptrace_scope
	$ exit

") or exit unless File.exists? settings.acq[:trace_filename][:bin]
		$stderr.puts("Incorrect output format, consider changing ct_row parameter.") or exit unless !ct[/\H/] and ct.length == 32
		
		# save trace
		FileUtils.mv settings.acq[:trace_filename][:bin], "#{settings.bin_traces_dir}/#{pt}_#{ct}"
	end
	puts
	# keep sample plaintext
	settings[:sample_pt] = pt
	
	# get mask
	alt = alt_mask(settings.bin_traces_dir)
	# filter traces
	filter(Dir["#{settings.bin_traces_dir}/*"], alt, :bin, true)
	# save mask to file
	mask_to_file(alt, settings.const_filter_file)
end

def get_txt_trace(settings)
	# acquire single text trace
	Open3.capture2([settings.acq[:txt], settings[:cmd], settings[:sample_pt]].join(" "))
	
	# filter this trace using the same mask
	filter([settings.acq[:trace_filename][:txt]], mask_from_file(settings.const_filter_file), :txt)
	# move full & filtered trace
	FileUtils.mv settings.acq[:trace_filename][:txt], "#{settings.traces_dir}/#{settings[:sample_pt]}"
	FileUtils.mv settings.acq[:trace_filename][:txt] + ".flt", settings.txt_trace
end