#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ ./#{File.basename(__FILE__)} <name> <attack_name> [-1 0 all 2b7e151628aed2a6abf7158809cf4f3c]

where
	 -1 ... number of traces, -1 ~ all
	  0 ... key byte, from range 0..15
	all ... attack target: all or 0x?? from '#{GS[:sboxes_dir]}' directory
	2b7e... expected key

") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

# read arguments
arg_attn = ARGV[1]
arg_ntr = ARGV[2]
arg_byte = ARGV[3]
arg_target = ARGV[4]
arg_key = ARGV[5]
# set number of traces
n_traces = set_n_traces(arg_ntr, settings)
# set attacked key byte
attack_byte = set_attack_byte(arg_byte)
# set attack target
target = set_target(arg_target)
# set expected key
exp_key = set_exp_key(arg_key)

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
	# ATTACK !!!
	run_attack(settings, arg_attn, n_traces, attack_byte, target_str, exp_key)
end

# next steps
tell_results_process(settings, arg_attn)
puts
