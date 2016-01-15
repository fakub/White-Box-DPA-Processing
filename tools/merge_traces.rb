def merge_traces(settings)
	if File.read("#{GS[:traces_dir]}/#{settings[:name]}.alt") == File.read("#{GS[:traces_dir]}/#{settings[:name]}__bkp.alt")
		FileUtils.mv Dir["#{GS[:traces_dir]}/#{settings[:name]}__bkp/*"], "#{GS[:traces_dir]}/#{settings[:name]}"
		FileUtils.rm_rf("#{GS[:traces_dir]}/#{settings[:name]}__bkp", secure: true)
		FileUtils.rm "#{GS[:traces_dir]}/#{settings[:name]}__bkp.alt"
	else
		puts "New traces have different alternating bits, merge aborted.
Old traces are kept in \"#{GS[:traces_dir]}/#{settings[:name]}__bkp\""
	end
end