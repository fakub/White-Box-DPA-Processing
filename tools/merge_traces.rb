def merge_traces(settings)
	if File.read(settings.const_filter_file__bkp) == File.read(settings.const_filter_file)
		# move new acquired traces
		FileUtils.mv Dir["#{settings.bin_traces_dir}/*"], settings.bin_traces_dir__bkp
		
		FileUtils.rm_rf(settings.path, secure: true)
		FileUtils.mv settings.path__bkp, settings.path
		
		# load previous settings (may contain more)
		reload_settings(settings)
		settings[:n_traces] = Dir["#{settings.bin_traces_dir}/*"].size
		puts "
Merge successful!"
		return true
	else
		puts "
New traces have different alternating bits, merge skipped.
Old traces are kept in \"#{settings.path__bkp}\""
		return false
	end
end
