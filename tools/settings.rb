class Settings
	def acq
		GS[:mode][self[:mode]]
	end
	def path
		"#{GS[:data_dir]}/#{self[:name]}"
	end
	def path__bkp
		"#{GS[:data_dir]}/#{self[:name]}__bkp"
	end
	def traces_dir
		"#{path}/#{GS[:traces_dir]}"
	end
	def traces_dir__bkp
		"#{path__bkp}/#{GS[:traces_dir]}"
	end
	def bin_traces_dir
		"#{traces_dir}/#{GS[:bin_subdir]}"
	end
	def bin_traces_dir__bkp
		"#{traces_dir__bkp}/#{GS[:bin_subdir]}"
	end
	def const_filter_file
		"#{traces_dir}/#{GS[:const_filter_filename]}.alt"
	end
	def const_filter_file__bkp
		"#{traces_dir__bkp}/#{GS[:const_filter_filename]}.alt"
	end
	def px_in_name
		"rpx-#{self[:rpixel_from]}-#{self[:rpixel_to]}__apx-#{self[:apixel_from]}-#{self[:apixel_to]}"
	end
	def flt_traces_dir
		"#{path}/#{GS[:flt_traces_dir]}__#{px_in_name}"
	end
	def range_filter_file
		"#{flt_traces_dir}/#{GS[:range_filter_filename]}__#{px_in_name}.msk"
	end
	def txt_trace
		"#{traces_dir}/#{self[:sample_pt]}.flt"
	end
	def flt_txt_trace
		"#{flt_traces_dir}/#{self[:sample_pt]}.flt.rge"
	end
	def png_preview
		"#{traces_dir}/#{self[:png_filename]}"
	end
	def flt_png_preview
		"#{flt_traces_dir}/trace.png"
	end
	def bin_flt_traces_dir
		"#{flt_traces_dir}/#{GS[:bin_subdir]}"
	end
	def attack_traces_dir
		has_key?(:rpixel_from) ? bin_flt_traces_dir : bin_traces_dir
	end
	def attack_txt_trace
		has_key?(:rpixel_from) ? flt_txt_trace : txt_trace
	end
	def visual_dir
		"#{path}/#{GS[:visual_dir]}"
	end
	def man_view_dir
		"#{visual_dir}/#{GS[:man_view_dir]}"
	end
	def arf_dir
		"#{visual_dir}/#{GS[:arf_dir]}"
	end
	def attack_dir
		"#{path}/#{GS[:attack_dir]}"
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
	s = Settings.new({name: name})
	$stderr.puts("File \"#{s.settings_file}\" not found") or exit \
		unless File.exists? s.settings_file
	return Settings.new(YAML.load(File.read(s.settings_file)))
end

def reload_settings(settings)
	$stderr.puts("File \"#{settings.settings_file}\" not found") or exit \
		unless File.exists? settings.settings_file
	return settings.reload(YAML.load(File.read(settings.settings_file)))
end
