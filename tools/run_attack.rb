# method which runs actual attack once everything is prepared

def run_attack(settings, arg_attn, n_traces, attack_byte, target, exp_key)
    # BitwiseDPA attack settings
    cas = {
        "dirname" => settings.attack_range_flt ? settings.bin_flt_traces_dir : settings.bin_traces_dir,
        "n_traces" => n_traces,
        "attack_byte" => attack_byte,
        "target" => target,
        "exp_key" => exp_key.pack("C*").unpack("H*").first
    }

    path = "#{settings.attack_dir}/#{arg_attn}"
    attack_name = "#{n_traces}_#{attack_byte}_#{target}"
    res_filename = "#{path}/#{attack_name}.yaml"
    log_filename = "/dev/null"

    # save BitwiseDPA attack settings
    cas_filename = "#{settings.cpp_attack_settings_dir}/#{arg_attn}_#{attack_name}.yaml"
    FileUtils.mkpath settings.cpp_attack_settings_dir
    File.write(cas_filename, YAML.dump(cas))

    # run BitwiseDPA attack
    unless File.exists? res_filename
        log = Open3.capture3([GS[:path_to_cpp_attack], cas_filename, ">", res_filename].join " ")[1]
        File.write(log_filename, log)
    end
end
