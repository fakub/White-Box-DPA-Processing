#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ #{File.basename(__FILE__)} name (n_traces=-1 expected_key=2b7e151628aed2a6abf7158809cf4f3c)") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

arg_ntr = ARGV[1]
arg_key = ARGV[2]

n_traces = (arg_ntr.to_i <= 0) ? settings[:n_traces] : arg_ntr.to_i
exp_key_str = arg_key.nil? ? GS[:default_key] : (!arg_key[/\H/] and arg_key.length == 32 ? arg_key : GS[:default_key])
exp_key = [exp_key_str].pack("H*").unpack("C*")

path = "#{settings.attack_dir}/#{n_traces}"

# init processed results
proc_res = {}

# search all available results
$stderr.puts "_" * Dir["#{path}/*.yaml"].size
Dir["#{path}/*.yaml"].each do |res_filename|
	$stderr.print "."
	
	next unless results = YAML.load(File.read(res_filename))
	
	# load results
	byte, target_str = File.basename(res_filename, ".yaml").split("_")
	byte = byte.to_i
	target = target_str.to_i 16
	
	results = results[byte]
	#~ 0:   # target bit
	#~ - - 0.5852212
	#~   - 43   # expected
	#~   - 8
	#~ - - 0.3354090
	#~   - 174
	#~   - 56
	
	proc_res[:bytes] = [] unless proc_res.has_key? :bytes
	proc_res[:bytes][byte] = {} if proc_res[:bytes][byte].nil?
	proc_res[:bytes][byte][:targets] = {} unless proc_res[:bytes][byte].has_key? :targets
	proc_res[:bytes][byte][:targets][target] = {} unless proc_res[:bytes][byte][:targets].has_key? target
	proc_res[:bytes][byte][true] = [] unless proc_res[:bytes][byte].has_key? true
	proc_res[:bytes][byte][false] = [] unless proc_res[:bytes][byte].has_key? false
	proc_res[:bytes][byte][:leak_bit] = [0] * 8 unless proc_res[:bytes][byte].has_key? :leak_bit
	
	# process results
	line = []
	cand_vals = {}
	8.times do |tb|
		gap = (results[tb][0][0] - results[tb][1][0]) / results[tb][0][0] * 100
		cand = results[tb][0][1]
		leak_index = results[tb][0][2]
		true_cand_pos = results[tb].index{|e|e[1] == exp_key[byte]}
		
		cand_vals[cand] = [] unless cand_vals.has_key? cand
		cand_vals[cand] << gap
		line << [gap, cand, leak_index, exp_key[byte] == cand, true_cand_pos]
	end
	
	proc_res[:bytes][byte][:targets][target][:line] = line
	proc_res[:bytes][byte][:targets][target][:cand_vals] = cand_vals
	proc_res[:bytes][byte][:targets][target][:true_cand] = exp_key[byte]
	
end
$stderr.puts

File.write("#{path}_results.yaml", YAML.dump(proc_res))
