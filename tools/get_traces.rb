def get_traces(settings, merge)
	if merge
		FileUtils.mv settings.path, "#{settings.path}__bkp"
	end
	
	FileUtils.mkpath(settings.traces_dir)
	prng = Random.new
	
	puts "\nAcquiring traces ..."
	puts "_" * settings.n_dots
	doti = 0
	
	pt = nil   # s.t. it persists outside the block
	
	settings[:n_traces].times do |i|
		if i*settings.n_dots >= settings[:n_traces]*doti; doti += 1; print "."; end   # progress bar
		
		pt = prng.bytes(16).unpack("H*").first
		ct = Open3.capture2([settings.acq[:bin], settings[:cmd], pt].join(" "))[0].split(/\n/)[settings[:ct_row]-1].gsub(/\s+/, "")
		
		$stderr.puts("
Trying `#{[settings.acq[:bin], settings[:cmd], pt].join(" ")}` but no result found.
PIN probably cannot instrument program due to certain OS limitations. Consider
	$ sudo su
	$ echo 0 > /proc/sys/kernel/yama/ptrace_scope
	$ exit") or exit unless File.exists? settings.acq[:trace_filename][:bin]
		$stderr.puts("Incorrect output format, consider changing ct_row parameter.") or exit unless !ct[/\H/] and ct.length == 32
		
		FileUtils.mv settings.acq[:trace_filename][:bin], "#{settings.traces_dir}/#{pt}_#{ct}"
	end
	puts
	
	return pt
end