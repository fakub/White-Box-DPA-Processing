def get_traces(settings)
	if Dir.exists?("#{GS[:traces_dir]}/#{settings[:name]}") and File.exists?("#{GS[:traces_dir]}/#{settings[:name]}.alt")
		print "Name \"#{settings[:name]}\" exists. Cancel (Ctrl+C) or merge new traces with existing? (Y/n) "
		if merge = $stdin.gets.chomp == "Y"
			FileUtils.mv "#{GS[:traces_dir]}/#{settings[:name]}", "#{GS[:traces_dir]}/#{settings[:name]}__bkp"
			FileUtils.mv "#{GS[:traces_dir]}/#{settings[:name]}.alt", "#{GS[:traces_dir]}/#{settings[:name]}__bkp.alt"
		else
			FileUtils.rm_rf("#{GS[:traces_dir]}/#{settings[:name]}", secure: true)
		end
	end
	
	FileUtils.mkpath("#{GS[:traces_dir]}/#{settings[:name]}")
	
	prng = Random.new
	
	puts "\nAcquiring traces ..."
	puts "_" * settings[:ndots]
	doti = 0
	
	pt = nil   # s.t. it persists outside the block
	
	settings[:n_traces].times do |i|
		if i*settings[:ndots] >= settings[:n_traces]*doti; doti += 1; print "."; end   # progress bar
		
		pt = prng.bytes(16).unpack("H*").first
		ct = Open3.capture2([settings[:acq][:bin], settings[:cmd], pt].join(" "))[0].split(/\n/)[settings[:ct_row]-1].gsub(/\s+/, "")
		
		$stderr.puts("PIN cannot instrument program due to certain OS limitations. Consider
	$ sudo su
	$ echo 0 > /proc/sys/kernel/yama/ptrace_scope
	$ exit") or exit unless File.exists? GS[:trace_filename][:bin]
		$stderr.puts("Incorrect output format, consider changing row_with_ciphertext parameter.") or exit unless !ct[/\H/] and ct.length == 32
		
		FileUtils.mv GS[:trace_filename][:bin], "#{GS[:traces_dir]}/#{settings[:name]}/#{pt}_#{ct}"
	end
	puts
	
	return pt, merge
end