def get_traces(settings)
	FileUtils.rm_rf("#{GS[:traces_dir]}/#{settings[:name]}", secure: true)
	FileUtils.mkdir("#{GS[:traces_dir]}/#{settings[:name]}")
	
	prng = Random.new
	
	puts "\nAcquiring traces ..."
	puts "_" * settings[:ndots]
	doti = 0
	
	pt = nil   # s.t. it persists outside the block
	
	settings[:n_traces].times do |i|
		if i*settings[:ndots] >= settings[:n_traces]*doti; doti += 1; print "."; end   # progress bar
		
		pt = prng.bytes(16).unpack("H*").first
		ct = Open3.capture2([settings[:acq][:bin], settings[:cmd], pt].join(" "))[0].split(/\n/)[settings[:ct_row]-1].gsub(/\s+/, "")
		
		$stderr.puts("Consider
		$ sudo su
		$ echo 0 > /proc/sys/kernel/yama/ptrace_scope") or exit unless File.exists? GS[:trace_filename][:bin]
		$stderr.puts("Incorrect output format, consider changing row_with_ciphertext parameter.") or exit unless !ct[/\H/] and ct.length == 32
		
		FileUtils.mv GS[:trace_filename][:bin], "#{GS[:traces_dir]}/#{settings[:name]}/#{pt}_#{ct}"
	end
	puts
	return pt
end