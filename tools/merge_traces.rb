# try to merge old & new traces if user decided so
# needs to check whether mask remains the same

def merge_traces(settings)
	if File.read(settings.const_filter_file__bkp) == File.read(settings.const_filter_file)
		# if masks are the same => can merge
		
		# move newly acquired traces
		FileUtils.mv Dir["#{settings.bin_traces_dir}/*"], settings.bin_traces_dir__bkp
		# remove old traces
		FileUtils.rm_rf(settings.path, secure: true)
		FileUtils.mv settings.path__bkp, settings.path
		
		# load previous settings (likely contain more)
		reload_settings(settings)
		# update number of traces
		settings[:n_traces] = Dir["#{settings.bin_traces_dir}/*"].size
		puts "
Merge successful!"
		return true
	else
		# if masks differ => cannot merge
		puts "
New traces have different alternating bits, merge skipped.
Old traces are kept in \"#{settings.path__bkp}\""
		return false
	end
end
