class Settings
	def acq
		GS[:mode][self[:mode]]
	end
	def path
		"#{GS[:data_dir]}/#{self[:name]}"
	end
	def traces_dir
		"#{path}/#{GS[:traces_dir]}"
	end
	def const_filter_file
		"#{path}/#{GS[:const_filter_filename]}.alt"
	end
	def visual_dir
		"#{path}/#{GS[:visual_dir]}"
	end
	def settings_file
		"#{path}/#{GS[:settings_filename]}.yaml"
	end
	def n_dots
		self[:n_traces] < GS[:n_dots_default] ? self[:n_traces] : GS[:n_dots_default]
	end
end

def gen_settings(filename)
	$stderr.puts("File #{filename} does not exist.") or exit unless File.exists? filename
	
	settings = Settings.new(YAML.load(File.read(filename)))
	$stderr.puts(":#{settings[:mode]} mode does not exist or has not been implemented yet.") or exit unless GS[:mode].has_key?(settings[:mode])
	
	settings[:n_traces] = GS[:n_traces_default] unless settings.has_key?(:n_traces)
	
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
		#~ settings.n_dots = settings[:n_traces] < GS[:n_dots_default] ? settings[:n_traces] : GS[:n_dots_default]
	#~ end
	#~ File.write("#{GS[:settings_dir]}/#{settings[:name]}.yaml", YAML.dump(settings))
	File.write(settings.settings_file, YAML.dump(settings.hash))
end

def load_settings(name)
	$stderr.puts("File #{GS[:data_dir]}/#{name}/#{GS[:settings_filename]}.yaml not found") or exit \
		unless File.exists? "#{GS[:data_dir]}/#{name}/#{GS[:settings_filename]}.yaml"
	return Settings.new(YAML.load(File.read("#{GS[:data_dir]}/#{name}/#{GS[:settings_filename]}.yaml")))
end
