def merge_traces(settings)
	#~ if Dir.exists?("#{GS[:traces_dir]}/#{settings[:name]}") and File.exists?("#{GS[:traces_dir]}/#{settings[:name]}.alt")
		#~ print "Name #{settings[:name]} exists. Merge new traces with existing? (Y/n) "
		#~ if merge = $stdin.gets.chomp == "Y"
			#~ FileUtils.mv "#{GS[:traces_dir]}/#{settings[:name]}", "#{GS[:traces_dir]}/#{settings[:name]}__bkp"
			#~ FileUtils.mv "#{GS[:traces_dir]}/#{settings[:name]}.alt", "#{GS[:traces_dir]}/#{settings[:name]}__bkp.alt"
		#~ else
			#~ FileUtils.rm_rf("#{GS[:traces_dir]}/#{settings[:name]}", secure: true)
		#~ end
	#~ end
	
	if File.read("#{GS[:traces_dir]}/#{settings[:name]}.alt") == File.read("#{GS[:traces_dir]}/#{settings[:name]}__bkp.alt")
		FileUtils.mv Dir["#{GS[:traces_dir]}/#{settings[:name]}__bkp/*"], "#{GS[:traces_dir]}/#{settings[:name]}"
		FileUtils.rm_rf("#{GS[:traces_dir]}/#{settings[:name]}__bkp", secure: true)
		FileUtils.rm "#{GS[:traces_dir]}/#{settings[:name]}__bkp.alt"
	else
		puts "New traces have different alternating bits, merge aborted.
Old traces are kept in \"#{GS[:traces_dir]}/#{settings[:name]}__bkp\""
	end
end