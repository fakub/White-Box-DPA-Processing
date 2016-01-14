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

cas_filename = "../cpp_attack/#{settings[:name]}.yaml"
File.write(cas_filename, YAML.dump(cas))

puts "Running attack ..."
puts log = Open3.capture2("../cpp_attack/attack #{cas_filename}")[0]
FileUtils.rm cas_filename

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

p = Plot.new

argmax.each do |row|
	row /= 8   # actual row in text trace
	addr = IO.readlines(txt_file)[row].split[1].hex
	
	apixel = (addr - addr_beg) / addr_div
	rpixel = row / row_div
	
	p.emph(rpixel, apixel, 1)
end

p.plot("#{GS[:visual_dir]}/#{settings[:name]}/emph.png")

puts "Check previous log to see how strong these candidates are. If OK, see \"#{GS[:visual_dir]}/#{settings[:name]}/emph.png\" -- this is where encryption probably takes place. Filter address & row range by
	$ ./#{MANFLT_FILE} #{settings[:name]}
Otherwise run attack without range filtering but keep in mind that it will be much slower, run
	$ cd ../cpp_attack
	$ ./attack copy_template_and_fill_own_settings.yaml"
