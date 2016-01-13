#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("Usage:
	$ #{File.basename(__FILE__)} name n_traces bytes=3") or exit if ARGV[1].nil?

# read arguments & set parameters
settings = {}
settings[:name] = ARGV[0]
settings[:n_traces] = ARGV[1].to_i.abs
settings[:bytes] = ARGV[2].nil? ? 3 : ((1..16).include?(ARGV[2].to_i) ? ARGV[2].to_i : 3)   #!# 3 -> glob settings

cas = {
	"dirname" => "../attack/#{GS[:traces_dir]}/#{settings[:name]}",
	"n_traces" => settings[:n_traces],
	"attack_bytes" => settings[:bytes],
	"targetbits" => [0, 1, 2, 3, 4, 5, 6, 7]
}

#~ cas_filename = "../cpp_attack/#{settings[:name]}.yaml"
#~ File.write(cas_filename, YAML.dump(cas))

#~ log = Open3.capture2("../cpp_attack/attack #{cas_filename}")[0]

#!# change cpp_attack's output log to find it easier -> argmax



argmax = [640, 648, 656]

txt_file = Dir["#{GS[:visual_dir]}/#{settings[:name]}/*.flt"].select{|f|f =~ /[0-9a-fA-F]{32}\.flt/}.first
png_file = Dir["#{GS[:visual_dir]}/#{settings[:name]}/*"].select{|f|f =~ /[0-9a-fA-F]{32}\.flt__[0-9a-fA-F]{12}\-\-[0-9a-fA-F]{12}__[0-9]+?x[0-9]+?\.png/}.first

addr_beg = png_file.match(/__[0-9a-fA-F]{12}\-\-[0-9a-fA-F]{12}__[0-9]+?x[0-9]+?\.png/).to_s.split("--")[0][2..-1].hex
addr_div = png_file.match(/__[0-9]+?x[0-9]+?\.png/).to_s.split("x")[1].split(".")[0].to_i
row_div = png_file.match(/__[0-9]+?x[0-9]+?\.png/).to_s.split("x")[0][2..-1].to_i

p = Plot.new

argmax.each do |row|
	row /= 8   # actual row in text trace
	addr = IO.readlines(txt_file)[row].split[1].hex
	
	apixel = (addr - addr_beg) / addr_div
	rpixel = row / row_div
	
	p.emph(rpixel, apixel, 1)
end

p.plot("#{GS[:visual_dir]}/#{settings[:name]}/emph.png")
