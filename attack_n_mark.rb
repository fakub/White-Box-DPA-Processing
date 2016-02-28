#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ #{File.basename(__FILE__)} name (n_traces=-1 bytes=16 hypothesis=sbox/rijinv expected_key=2b7e151628aed2a6abf7158809cf4f3c)

where
	rijinv stands for Rijndael inverse, and
	expected_key can be partial.") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

arg_ntr = ARGV[1]
arg_bytes = ARGV[2]
arg_hyp = ARGV[3]
arg_key = ARGV[4]


try_n_traces = (arg_ntr.to_i <= 0) ? settings[:n_traces] : arg_ntr.to_i
try_attack_bytes = (1..16).include?(arg_bytes.to_i) ? arg_bytes.to_i : 16
$stderr.puts("Warning: invalid hypothesis. Using deafult hypothesis #{GS[:possible_targets].first}.") unless GS[:possible_targets].include? arg_hyp
hyp = arg_hyp.nil? ? GS[:possible_targets].first : (GS[:possible_targets].include? arg_hyp ? arg_hyp : GS[:possible_targets].first)
$stderr.puts("Warning: invalid expected key. Using deafult key #{GS[:default_key]}.") if !arg_key.nil? and (arg_key[/\H/] or arg_key.length > 32)
exp_key = arg_key.nil? ? GS[:default_key] : (!arg_key[/\H/] and arg_key.length <= 32 ? arg_key : GS[:default_key])

FileUtils.mkpath(settings.attack_dir)

cas = {
	"dirname" => settings.attack_traces_dir,
	"n_traces" => try_n_traces,
	"attack_bytes" => try_attack_bytes,
	"target" => hyp,
	"exp_key" => exp_key
}

attack_name = "ntr-#{try_n_traces}_by-#{try_attack_bytes}_hyp-#{hyp}_key-#{exp_key}"
cas_filename = "#{settings.attack_dir}/settings__#{attack_name}.yaml"
res_filename = "#{settings.attack_dir}/#{attack_name}__results.yaml"
log_filename = "#{settings.attack_dir}/#{attack_name}.log"
File.write(cas_filename, YAML.dump(cas))

log = Open3.capture3([GS[:path_to_cpp_attack], cas_filename, ">", res_filename].join " ")[1]
File.write(log_filename, log)

log = log.split(/Attacking[\W]+?[\d]+?\.\Wbyte\W\.\.\./)
log.slice!(0)

argmax = []

log.each do |lb|
	argmax << lb.split("New local max: ").last.split(/\n/)[2].split("|")[3].to_i
end

addr_beg = settings[:addr_beg]
addr_div = settings[:addr_div]
row_div = settings[:row_div]

addrs = []
p = Plot.new

argmax.each do |row|
	row /= 8   # actual row in text trace
	addrs << IO.readlines(settings.attack_txt_trace)[row].split[1].hex
	
	apixel = (addrs.last - addr_beg) / addr_div
	rpixel = row / row_div
	
	p.emph(rpixel, apixel, 1)
end

# ======================================================================

p.plot("#{settings.traces_dir}/emph.png")

#!# dává špatnou adresu !!!
leak_log = "
!!! THE FOLLOWING IS INCORRECT !!!
o==============================================================================o
| With plaintext #{File.basename(settings.attack_txt_trace, ".*")} leaking at:                  |
#{addrs.map{|a|"|   0x" + a.to_s(16) + " "*(73-a.to_s(16).length)}.join("|\n")}|
o==============================================================================o"

puts leak_log
#~ File.append("#{GS[:traces_dir]}/#{settings[:name]}__ntraces-#{try_n_traces}_bytes-#{try_attack_bytes}.log", leak_log)

puts "Check previous log to see how strong these candidates are. If OK, see \"#{settings.traces_dir}/emph.png\" -- this is where encryption probably takes place. You can filter address & row range by
	$ ./#{MANFLT_FILE} #{settings[:name]}
If you have finished attack you can use leaking addresses to find out where the implementation leaks (e.g. in GDB)."
