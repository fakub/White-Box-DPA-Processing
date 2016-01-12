#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("Usage:
	$ #{File.basename(__FILE__)} name") or exit if ARGV[0].nil?

# read arguments & set parameters
settings = {}
settings[:name] = ARGV[0]
settings[:n_traces] = Dir["#{GS[:traces_dir]}/#{settings[:name]}/*"].size
settings[:ndots] = settings[:n_traces] < GS[:ndots_default] ? settings[:n_traces] : GS[:ndots_default]


flt_orig_png = Dir["#{GS[:visual_dir]}/#{settings[:name]}/*"].select{|f|f =~ /[0-9a-fA-F]{32}\.(flt|orig)__[0-9a-fA-F]{12}\-\-[0-9a-fA-F]{12}__[0-9]+?x[0-9]+?\.png/}

puts "See\n\t#{flt_orig_png[0]}\nand\n\t#{flt_orig_png[1]}"
print "Do you wish to filter addresses based on .flt or .orig image? (flt/orig) "
until [:flt, :orig].include?(fo = $stdin.gets.chomp.to_sym)
	$stderr.print("Invalid flt/orig. Try again: ")
end

txt_file = {}
txt_file[:flt] = Dir["#{GS[:visual_dir]}/#{settings[:name]}/*.flt"].select{|f|f =~ /[0-9a-fA-F]{32}\.flt/}.first
txt_file[:orig] = Dir["#{GS[:visual_dir]}/#{settings[:name]}/*.orig"].select{|f|f =~ /[0-9a-fA-F]{32}\.orig/}.first
png_file = Dir["#{GS[:visual_dir]}/#{settings[:name]}/*.png"].select{|f|f =~ /[0-9a-fA-F]{32}\.#{fo}__/}.first
addr_beg = png_file.match(/__[0-9a-fA-F]{12}\-\-[0-9a-fA-F]{12}__[0-9]+?x[0-9]+?\.png/).to_s.split("--")[0][2..-1].hex
addr_div = png_file.match(/__[0-9]+?x[0-9]+?\.png/).to_s.split("x")[1].split(".")[0].to_i

i = 0
altfiles = []
pngfiles = []

begin
	puts "Check #{png_file} and provide desired address range in pixels from left."
	
	begin
		print "Pixel from: "
		pixel_from = $stdin.gets.to_i
		print "Pixel to:   "
		pixel_to = $stdin.gets.to_i
	end until pixel_from < pixel_to or $stderr.puts("Pixel from must be smaller than Pixel to.")
	
	addr_from = addr_beg + pixel_from * addr_div
	addr_to = addr_beg + pixel_to * addr_div
	
	mask = File.read(txt_file[:flt]).split("\n").map do |line|
		addr = line.split[1].hex
		addr >= addr_from and addr <= addr_to
	end
	
	altfilename = "./#{GS[:visual_dir]}/#{settings[:name]}/#{fo}__px--#{pixel_from}--#{pixel_to}__addr--%0#{2*GS[:addr_len]}x--%0#{2*GS[:addr_len]}x.alt" % [addr_from, addr_to]
	alt_to_file(mask, altfilename)
	altfiles << altfilename
	
	previewfile = gen_view(txt_file[fo], addr_from, addr_to, 0, Float::INFINITY, 1, nil, nil)
	i += 1
	
	if File.basename(previewfile[0]) == File.basename(png_file)
		FileUtils.cp previewfile[0], "./#{GS[:visual_dir]}/#{settings[:name]}/%02d.png" % [i]
	else
		FileUtils.mv previewfile[0], "./#{GS[:visual_dir]}/#{settings[:name]}/%02d.png" % [i]
	end
	pngfiles << "./#{GS[:visual_dir]}/#{settings[:name]}/%02d.png" % [i]
	
	puts "\nCheck #{"%02d.png" % [i]}, if it is OK, use #{altfilename} as altfile for next step."
	print "Start filtering with this range? (Y/n) "
end until $stdin.gets.chomp == "Y"

FileUtils.rm altfiles[0..-2]
FileUtils.rm pngfiles

# copy binary traces
FileUtils.rm_rf("#{GS[:traces_dir]}/#{settings[:name]}__#{fo}__px--#{pixel_from}--#{pixel_to}", secure: true)
FileUtils.mkdir("#{GS[:traces_dir]}/#{settings[:name]}__#{fo}__px--#{pixel_from}--#{pixel_to}")
FileUtils.cp(Dir["#{GS[:traces_dir]}/#{settings[:name]}/*"], "#{GS[:traces_dir]}/#{settings[:name]}__#{fo}__px--#{pixel_from}--#{pixel_to}")

# use altfilename
filter(Dir["#{GS[:traces_dir]}/#{settings[:name]}__#{fo}__px--#{pixel_from}--#{pixel_to}/*"], alt_from_file(altfilename), :bin)