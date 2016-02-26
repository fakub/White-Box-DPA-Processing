def merge_traces(settings)
	if File.read(settings[:const_filter_file]) == File.read(settings[:const_filter_file] + "__bkp")
		FileUtils.mv Dir["#{settings[:traces_dir]}__bkp/*"], settings[:traces_dir]
		FileUtils.rm_rf("#{settings[:traces_dir]}__bkp", secure: true)
		FileUtils.rm settings[:const_filter_file] + "__bkp"
	else
		puts "New traces have different alternating bits, merge aborted.
Old traces are kept in \"#{settings[:traces_dir]}__bkp\""
	end
end