def merge_traces(settings)
	if File.read("#{settings.path}__bkp/#{GS[:const_filter_filename]}.alt") == File.read(settings.const_filter_file)
		FileUtils.mv Dir["#{settings.path}__bkp/#{GS[:traces_dir]}/*"], settings.traces_dir
		FileUtils.rm_rf("#{settings.path}__bkp", secure: true)
		puts "
Merge successful!"
		return true
	else
		puts "
New traces have different alternating bits, merge skipped.
Old traces are kept in \"#{settings.path}__bkp\""
		return false
	end
end