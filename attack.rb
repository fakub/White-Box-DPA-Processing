#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ ./#{File.basename(__FILE__)} name attack_name [-1 0 all 2b7e151628aed2a6abf7158809cf4f3c]

where
	 -1 ... number of traces, -1 ~ all
	  0 ... key byte, from range 0..15
	all ... attack target: all or 0x?? from '#{GS[:sboxes_dir]}' directory
	2b7e... expected key

") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

arg_attn = ARGV[1]
arg_ntr = ARGV[2]
arg_byte = ARGV[3]
arg_target = ARGV[4]
arg_key = ARGV[5]

# set number of traces
n_traces = (arg_ntr.to_i <= 0) ? settings[:n_traces] : arg_ntr.to_i
# set attacked key byte
attack_byte = (0..15).include?(arg_byte.to_i) ? arg_byte.to_i : 0
# set attack target
target = arg_target.nil? ? "all" : arg_target
# set expected key
if arg_key.nil? or (!arg_key.nil? and (arg_key[/\H/] or arg_key.length != 32))
	$stderr.puts("Warning: invalid expected key. Using deafult key '#{GS[:default_key]}'") unless arg_key.nil?
	exp_key_str = GS[:default_key]
else
	exp_key_str = arg_key
end
exp_key = [exp_key_str].pack("H*").unpack("C*")

# prepare attack directory
path = "#{settings.attack_dir}/#{arg_attn}"
FileUtils.mkpath(path)

# run attack(s)
puts "Attacking #{attack_byte}. byte using #{n_traces} traces."

256.times do |target_int|
	next if (target != "all") ^ (target_int == 0)
	target_str = target == "all" ? "0b%08b" % [target_int] : target
	target_file = "#{GS[:sboxes_dir]}/#{target_str}"
	raise "Invalid target! File #{target_file} not found." unless File.exists?(target_file)
	puts "\ttarget: #{target_str}"
	run_attack(settings, arg_attn, n_traces, attack_byte, target_str, exp_key_str)
end
