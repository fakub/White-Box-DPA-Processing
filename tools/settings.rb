def save_settings(settings, merge = true)
	FileUtils.mkpath("#{GS[:settings_dir]}")
	# backup unless merge
	if File.exists?("#{GS[:settings_dir]}/#{settings[:name]}.yaml") and not merge
		FileUtils.mv "#{GS[:settings_dir]}/#{settings[:name]}.yaml", "#{GS[:settings_dir]}/#{settings[:name]}__bkp.yaml"
	end
	# set new n_traces if merge
	if merge
		settings[:n_traces] = Dir["#{GS[:traces_dir]}/#{settings[:name]}/*"].size if merge
		settings[:ndots] = settings[:n_traces] < GS[:ndots_default] ? settings[:n_traces] : GS[:ndots_default]
	end
	File.write("#{GS[:settings_dir]}/#{settings[:name]}.yaml", YAML.dump(settings))
end

def load_settings(name)
	$stderr.puts("Fatal: file \"#{GS[:settings_dir]}/#{name}.yaml\" not found.") or exit \
		unless File.exists?("#{GS[:settings_dir]}/#{name}.yaml")
	
	$stderr.puts("Fatal: dir \"#{GS[:traces_dir]}/#{name}\" not found.") or exit \
		unless Dir.exists?("#{GS[:traces_dir]}/#{name}")
	
	$stderr.puts("Fatal: dir \"#{GS[:visual_dir]}/#{name}\" not found.") or exit \
		unless Dir.exists?("#{GS[:visual_dir]}/#{name}")
	
	settings = YAML.load(File.read("#{GS[:settings_dir]}/#{name}.yaml"))
	
	$stderr.puts("Warning: different amount of traces than claimed in settings.") \
		unless settings[:n_traces] == Dir["#{GS[:traces_dir]}/#{name}/*"].size
	
	return settings
end