#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ ./#{File.basename(__FILE__)} <name> <attack_name> [2b7e151628aed2a6abf7158809cf4f3c]

where
	2b7e... expected key

") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

# read arguments
arg_attn = ARGV[1]
arg_key = ARGV[2]
# set expected key
exp_key = set_exp_key(arg_key)

# set path
path = "#{settings.attack_dir}/#{arg_attn}"

# init processed results
proc_res = {}

# search all available results
$stderr.puts "_" * (Dir["#{path}/*.yaml"].size / 0x10)
i=0

Dir["#{path}/*.yaml"].each do |res_filename|
	$stderr.print "." if i & 0xf == 0
	i += 1
	
	next unless results = YAML.load(File.read(res_filename))
	
	# load results
	n_traces, byte, target_str = File.basename(res_filename, ".yaml").split("_")
	byte = byte.to_i
	
	# sample results (in YAML)
	#~ 0:   # target bit, might be only one
	#~ - - 0.5852212
	#~   - 43   # expected
	#~   - 8
	#~ - - 0.3354090
	#~   - 174
	#~   - 56
	
	proc_res[:bytes] = [] unless proc_res.has_key? :bytes
	proc_res[:bytes][byte] = {} if proc_res[:bytes][byte].nil?
	proc_res[:bytes][byte][:targets] = {} unless proc_res[:bytes][byte].has_key? :targets
	# target_str moved
	proc_res[:bytes][byte][:true_cand] = exp_key[byte] unless proc_res[:bytes][byte].has_key? :true_cand
	proc_res[:bytes][byte][true] = [] unless proc_res[:bytes][byte].has_key? true
	proc_res[:bytes][byte][false] = [] unless proc_res[:bytes][byte].has_key? false
	proc_res[:bytes][byte][:leak_bit] = [0] * 8 unless proc_res[:bytes][byte].has_key? :leak_bit
	
	# process results
	results.each do |tbit, res_tb|
		gap = (res_tb[0][0] - res_tb[1][0]) / res_tb[0][0] * 100
		cand = res_tb[0][1]
		leak_index = res_tb[0][2]
		true_cand_pos = res_tb.index{|e|e[1] == exp_key[byte]}
		
		t_str = results.size > 1 ? target_str + "/#{tbit}" : target_str
		proc_res[:bytes][byte][:targets][t_str] = {} unless proc_res[:bytes][byte][:targets].has_key? t_str
		proc_res[:bytes][byte][:targets][t_str][:gap] = gap
		proc_res[:bytes][byte][:targets][t_str][:cand] = cand
		proc_res[:bytes][byte][:targets][t_str][:leak_index] = leak_index
		proc_res[:bytes][byte][:targets][t_str][:true_cand_pos] = true_cand_pos
		proc_res[:bytes][byte][:targets][t_str][:correct] = exp_key[byte] == cand
	end
end
$stderr.puts

# write results
File.write("#{path}_results.yaml", YAML.dump(proc_res))

# next steps
tell_results_disp(settings, arg_attn)
puts
