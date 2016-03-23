#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ #{File.basename(__FILE__)} name attack_name (expected_key=2b7e151628aed2a6abf7158809cf4f3c)

") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

arg_attn = ARGV[1]
arg_key = ARGV[2]

exp_key_str = arg_key.nil? ? GS[:default_key] : (!arg_key[/\H/] and arg_key.length == 32 ? arg_key : GS[:default_key])
exp_key = [exp_key_str].pack("H*").unpack("C*")

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
	
	#~ - - 0.5852212
	#~   - 43   # expected
	#~   - 8
	#~ - - 0.3354090
	#~   - 174
	#~   - 56
	
	proc_res[:bytes] = [] unless proc_res.has_key? :bytes
	proc_res[:bytes][byte] = {} if proc_res[:bytes][byte].nil?
	proc_res[:bytes][byte][:targets] = {} unless proc_res[:bytes][byte].has_key? :targets
	proc_res[:bytes][byte][:targets][target_str] = {} unless proc_res[:bytes][byte][:targets].has_key? target_str
	proc_res[:bytes][byte][:true_cand] = exp_key[byte] unless proc_res[:bytes][byte].has_key? :true_cand
	proc_res[:bytes][byte][true] = [] unless proc_res[:bytes][byte].has_key? true
	proc_res[:bytes][byte][false] = [] unless proc_res[:bytes][byte].has_key? false
	proc_res[:bytes][byte][:leak_bit] = [0] * 8 unless proc_res[:bytes][byte].has_key? :leak_bit
	
	# process results
	gap = (results[0][0] - results[1][0]) / results[0][0] * 100
	cand = results[0][1]
	leak_index = results[0][2]
	true_cand_pos = results.index{|e|e[1] == exp_key[byte]}
	
	proc_res[:bytes][byte][:targets][target_str][:gap] = gap
	proc_res[:bytes][byte][:targets][target_str][:cand] = cand
	proc_res[:bytes][byte][:targets][target_str][:leak_index] = leak_index
	proc_res[:bytes][byte][:targets][target_str][:true_cand_pos] = true_cand_pos
	proc_res[:bytes][byte][:targets][target_str][:correct] = exp_key[byte] == cand
end
$stderr.puts

File.write("#{path}_results.yaml", YAML.dump(proc_res))
