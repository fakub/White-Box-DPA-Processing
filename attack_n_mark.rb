#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("Usage:
	$ #{File.basename(__FILE__)} name (n_traces=-1 bytes=16)") or exit if ARGV[0].nil?

settings = load_settings(ARGV[0])


try_n_traces = (ARGV[1].to_i <= 0) ? settings[:n_traces] : ARGV[1].to_i
try_attack_bytes = ARGV[2].nil? ? 16 : ((1..16).include?(ARGV[2].to_i) ? ARGV[2].to_i : 16)

cas = {
	"dirname" => "#{GS[:traces_dir]}/#{settings[:name]}",
	"n_traces" => try_n_traces,
	"attack_bytes" => try_attack_bytes   #,
	# "targetbits" => [0, 1, 2, 3, 4, 5, 6, 7]
}

cas_filename = "#{GS[:traces_dir]}/#{settings[:name]}.yaml"
File.write(cas_filename, YAML.dump(cas))

puts "Running attack ..."
puts log = Open3.capture2("../cpp_attack/attack #{cas_filename}")[0]
File.write("#{GS[:traces_dir]}/#{settings[:name]}__ntr-#{try_n_traces}_by-#{try_attack_bytes}.log", log)

log = log.split(/Attacking[\W]+?[\d]+?\.\Wbyte\W\.\.\./)
log.slice!(0)

argmax = []

log.each do |lb|
	argmax << lb.split("New local max: ").last.split(/\n/)[2].split("|")[3].to_i
end

txt_file = Dir["#{GS[:visual_dir]}/#{settings[:name]}/*.flt"].select{|f|f =~ /[0-9a-fA-F]{32}\.flt/}.first
png_file = Dir["#{GS[:visual_dir]}/#{settings[:name]}/*"].select{|f|f =~ /[0-9a-fA-F]{32}\.flt__[0-9a-fA-F]{12}\-\-[0-9a-fA-F]{12}__[0-9]+?x[0-9]+?\.png/}.first

addr_beg = png_file.match(/__[0-9a-fA-F]{12}\-\-[0-9a-fA-F]{12}__[0-9]+?x[0-9]+?\.png/).to_s.split("--")[0][2..-1].hex
addr_div = png_file.match(/__[0-9]+?x[0-9]+?\.png/).to_s.split("x")[1].split(".")[0].to_i
row_div = png_file.match(/__[0-9]+?x[0-9]+?\.png/).to_s.split("x")[0][2..-1].to_i

addrs = []
p = Plot.new

argmax.each do |row|
	row /= 8   # actual row in text trace
	addrs << IO.readlines(txt_file)[row].split[1].hex
	
	apixel = (addrs.last - addr_beg) / addr_div
	rpixel = row / row_div
	
	p.emph(rpixel, apixel, 1)
end

p.plot("#{GS[:visual_dir]}/#{settings[:name]}/emph.png")
puts "
o==============================================================================o
| Leaking at:                                                                  |
#{addrs.map{|a|"|   0x" + a.to_s(16) + " "*(73-a.to_s(16).length)}.join("|\n")}|
o==============================================================================o"

puts "Check previous log to see how strong these candidates are. If OK, see \"#{GS[:visual_dir]}/#{settings[:name]}/emph.png\" -- this is where encryption probably takes place. You can filter address & row range by
	$ ./#{MANFLT_FILE} #{settings[:name]}
If you have finished attack you can use leaking addresses to find out where the implementation leaks (e.g. in GDB)."
