def run_attack(settings, n_traces, attack_byte, target, exp_key_str)
	cas = {
		"dirname" => settings.attack_range_flt ? settings.bin_flt_traces_dir : settings.bin_traces_dir,
		"n_traces" => n_traces,
		"attack_byte" => attack_byte,
		"target" => target,
		"exp_key" => exp_key_str
	}
	exp_key = [exp_key_str].pack("H*").unpack("C*")
	
	path = "#{settings.attack_dir}/#{n_traces}"
	attack_name = "#{attack_byte}_0x#{target}"
	res_filename = "#{path}/#{attack_name}.yaml"
	#~ log_filename = "#{path}/#{attack_name}.log"
	log_filename = "/dev/null"
	
	# save C++ attack settings
	cas_filename = "#{settings.cpp_attack_settings_dir}/#{n_traces}_#{attack_name}.yaml"
	FileUtils.mkpath settings.cpp_attack_settings_dir
	File.write(cas_filename, YAML.dump(cas))
	
	# run attack
	unless File.exists? res_filename
		log = Open3.capture3([GS[:path_to_cpp_attack], cas_filename, ">", res_filename].join " ")[1]
		File.write(log_filename, log)
	end
	
	#~ return YAML.load(File.read(res_filename))
end