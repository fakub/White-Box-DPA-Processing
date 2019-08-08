# set variables from arguments

def set_n_traces(arg_ntr, settings)
    (arg_ntr.to_i <= 0) ? settings[:n_traces] : arg_ntr.to_i
end

def set_attack_byte(arg_byte)
    (0..15).include?(arg_byte.to_i) ? arg_byte.to_i : 0
end

def set_target(arg_target)
    arg_target.nil? ? "all" : arg_target
end

def set_exp_key(arg_key)
    if arg_key.nil? or (!arg_key.nil? and (arg_key[/\H/] or arg_key.length != 32))
        $stderr.puts("Warning: invalid expected key. Using deafult key '#{GS[:default_key]}'") unless arg_key.nil?
        exp_key_str = GS[:default_key]
    else
        exp_key_str = arg_key
    end
    return [exp_key_str].pack("H*").unpack("C*")
end

