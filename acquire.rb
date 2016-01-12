#!/usr/bin/env ruby

require "open3"
require "fileutils"
require "./tools/all.rb"

# print help
$stderr.puts("Usage:
	$ #{File.basename(__FILE__)} ra/(rc)/(wa)/wc \"AES command\" row_with_ciphertext name (n_traces = 32)
		where
			ra ... Read Address,
			rc ... Read Content, not implemented yet,
			wa ... Write Address, not implemented yet,
			wc ... Write Content ") or exit if ARGV[2].nil?

# check ASLR OFF
$stderr.print("Is ASLR really OFF? (Y/n) ")
isoff = $stdin.gets.chomp
$stderr.puts("Consider
	$ setarch `uname -m` -R /bin/bash") or exit unless isoff == "Y"

# read arguments & set parameters
settings = {}
settings[:acq] = case ARGV[0]
when "ra"
	{bin: "../pin-2.14-71313-gcc.4.4.7-linux/pin -t ../pin-2.14-71313-gcc.4.4.7-linux/source/tools/MemoryTracer/obj-intel64/TracerByTeuwen_read_addr.so --",
	txt: "../pin-2.14-71313-gcc.4.4.7-linux/pin -t ../pin-2.14-71313-gcc.4.4.7-linux/source/tools/MemoryTracer/obj-intel64/MemoryTracer_read_addr.so --"}
when "rc"
	$stderr.puts("Read Content has not been implemented yet.") or exit
when "wa"
	$stderr.puts("Write Address has not been implemented yet.") or exit
when "wc"
	{bin: "../pin-2.14-71313-gcc.4.4.7-linux/pin -t ../pin-2.14-71313-gcc.4.4.7-linux/source/tools/MemoryTracer/obj-intel64/TracerByTeuwen.so --",
	txt: "../pin-2.14-71313-gcc.4.4.7-linux/pin -t ../pin-2.14-71313-gcc.4.4.7-linux/source/tools/MemoryTracer/obj-intel64/MemoryTracer.so --"}
else
	$stderr.puts("Invalid first argument.") or exit
end
settings[:cmd] = ARGV[1]
settings[:ct_row] = ARGV[2].to_i
settings[:name] = ARGV[3]
settings[:n_traces] = ARGV[4].nil? ? 10 : ARGV[4].to_i
settings[:ndots] = settings[:n_traces] < NDOTS_DEFAULT ? settings[:n_traces] : NDOTS_DEFAULT


# acquire & save traces
sample_pt = get_traces(settings)

# create & use & save mask of alternating bytes of traces (non-constant ones)
alt = alt_mask(settings)
filter(Dir["#{TRACES_DIR}/#{settings[:name]}/*"], alt, :bin, true)
alt_to_file(alt, "#{TRACES_DIR}/#{settings[:name]}.alt")

# acquire sample pt again to text & create preview
flt_orig_png = trace_preview(settings, sample_pt, alt)

# sofar OK


puts "See #{flt_orig_png[0]} and #{flt_orig_png[1]}."
print "Do you wish to filter addresses based on .flt or .orig image? (flt/orig) "
until [:flt, :orig].include?(fo = $stdin.gets.chomp.to_sym)
	$stderr.print("Invalid flt/orig. Try again: ")
end

txt_file = {}
txt_file[:flt] = Dir["#{VISUAL_DIR}/*.flt"].select{|f|f =~ /#{settings[:name]}_[0-9a-fA-F]{32}\.flt/}.first
txt_file[:orig] = Dir["#{VISUAL_DIR}/*.orig"].select{|f|f =~ /#{settings[:name]}_[0-9a-fA-F]{32}\.orig/}.first
png_file = Dir["#{VISUAL_DIR}/*.png"].select{|f|f =~ /#{settings[:name]}_[0-9a-fA-F]{32}\.#{fo}__/}.first
addr_beg = png_file.match(/__[0-9a-fA-F]{12}\-\-[0-9a-fA-F]{12}__[0-9]+?x[0-9]+?\.png/).to_s.split("--")[0][2..-1].hex
addr_div = png_file.match(/__[0-9]+?x[0-9]+?\.png/).to_s.split("x")[1].split(".")[0].to_i

i = 0

begin
	puts "Check #{png_file} and provide desired address range in pixels from left."
	
	print "Pixel from: "
	pixel_from = $stdin.gets.to_i
	print "Pixel to:   "
	pixel_to = $stdin.gets.to_i
	
	$stderr.puts("Address from must be smaller than address to.") or exit unless pixel_from < pixel_to
	
	addr_from = addr_beg + pixel_from * addr_div
	addr_to = addr_beg + pixel_to * addr_div
	
	mask = File.read(txt_file[:flt]).split("\n").map do |line|
		addr = line.split[1].hex
		addr >= addr_from and addr <= addr_to
	end
	
	altfilename = "./#{VISUAL_DIR}/#{settings[:name]}__%0#{2*ADDR_LEN}x--%0#{2*ADDR_LEN}x.alt" % [addr_from, addr_to]
	alt_to_file(mask, altfilename)
	
	previewfiles = gen_view(txt_file[fo], addr_from, addr_to, 0, Float::INFINITY, 1, nil, nil)
	i += 1
	FileUtils.mv previewfiles[0] + ".png", "%02d.png" % [i]
	
	puts "\nCheck #{"%02d.png" % [i]}, if it is OK, use #{altfilename} as altfile for next step."
	print "Start filtering with this range? (Y/n) "
end until $stdin.gets.chomp == "Y"

puts "Now I will filter it with #{altfilename}"