def gen_settings(filename)
	$stderr.puts("File #{filename} does not exist.") or exit unless File.exists? filename
	
	settings = YAML.load(File.read(filename))
	
	settings[:acq] = GS[:mode].has_key?(settings[:mode]) ? GS[:mode][settings[:mode]] : ($stderr.puts(":#{settings[:mode]} mode does not exist or has not been implemented yet.") or exit)
	settings[:n_traces] = GS[:n_traces_default] unless settings.has_key?(:n_traces)
	
	settings[:n_dots] = settings[:n_traces] < GS[:n_dots_default] ? settings[:n_traces] : GS[:n_dots_default]
	settings[:path] = "#{GS[:data_dir]}/#{settings[:name]}"
	
	settings[:traces_dir] = "#{settings[:path]}/#{GS[:traces_dir]}"
	settings[:const_filter_file] = "#{settings[:path]}/#{GS[:const_filter_filename]}.alt"
	settings[:visual_dir] = "#{settings[:path]}/#{GS[:visual_dir]}"
	settings[:settings_file] = "#{settings[:path]}/#{GS[:settings_filename]}.yaml"
	
	return settings
end

def save_settings(settings)
#~ def save_settings(settings, merge = true)
	#~ # backup unless merge
	#~ if File.exists?("#{GS[:settings_dir]}/#{settings[:name]}.yaml") and not merge
		#~ FileUtils.mv "#{GS[:settings_dir]}/#{settings[:name]}.yaml", "#{GS[:settings_dir]}/#{settings[:name]}__bkp.yaml"
	#~ end
	#~ # set new n_traces if merge
	#~ if merge
		#~ settings[:n_traces] = Dir["#{GS[:traces_dir]}/#{settings[:name]}/*"].size if merge
		#~ settings[:n_dots] = settings[:n_traces] < GS[:n_dots_default] ? settings[:n_traces] : GS[:n_dots_default]
	#~ end
	#~ File.write("#{GS[:settings_dir]}/#{settings[:name]}.yaml", YAML.dump(settings))
	File.write(settings[:settings_file], YAML.dump(settings))
end

def load_settings(name)
	$stderr.puts("File #{GS[:data_dir]}/#{name}/#{GS[:settings_filename]}.yaml not found") or exit \
		unless File.exists? "#{GS[:data_dir]}/#{name}/#{GS[:settings_filename]}.yaml"
	return YAML.load(File.read("#{GS[:data_dir]}/#{name}/#{GS[:settings_filename]}.yaml"))
end
