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

txt_file = Dir["#{GS[:visual_dir]}/#{settings[:name]}/*.flt"].select{|f|f =~ /[0-9a-fA-F]{32}\.flt/}.first
png_file = Dir["#{GS[:visual_dir]}/#{settings[:name]}/*"].select{|f|f =~ /[0-9a-fA-F]{32}\.flt__[0-9a-fA-F]{12}\-\-[0-9a-fA-F]{12}__[0-9]+?x[0-9]+?\.png/}.first

addr_beg = png_file.match(/__[0-9a-fA-F]{12}\-\-[0-9a-fA-F]{12}__[0-9]+?x[0-9]+?\.png/).to_s.split("--")[0][2..-1].hex
addr_div = png_file.match(/__[0-9]+?x[0-9]+?\.png/).to_s.split("x")[1].split(".")[0].to_i
row_div = png_file.match(/__[0-9]+?x[0-9]+?\.png/).to_s.split("x")[0][2..-1].to_i

puts "Previously you have checked
	#{png_file}."

i = 0
altfiles = Set.new
pngfiles = Set.new

begin
	puts "Now provide desired address range in pixels from left."
	
	begin
		print "Address pixel from: "
		apixel_from = $stdin.gets.to_i.abs
		print "Address pixel to:   "
		apixel_to = $stdin.gets.to_i
		apixel_to = (apixel_to <= 0) ? 0xffffffffffff : apixel_to
		print "Row pixel from: "
		rpixel_from = $stdin.gets.to_i.abs
		print "Row pixel to:   "
		rpixel_to = $stdin.gets.to_i
		rpixel_to = (rpixel_to <= 0) ? 0xffffffffffff : rpixel_to
	end until (apixel_from < apixel_to and rpixel_from < rpixel_to) or $stderr.puts("Pixel from must be smaller than Pixel to.")
	
	addr_from = addr_beg + apixel_from * addr_div
	addr_to = addr_beg + apixel_to * addr_div
	row_from = rpixel_from * row_div
	row_to = rpixel_to * row_div
	
	mask = File.read(txt_file).split("\n").map.with_index do |line,row|
		addr = line.split[1].hex
		addr >= addr_from and addr <= addr_to and row >= row_from and row <= row_to
	end
	
	px_in_name = "rpx-#{rpixel_from}-#{rpixel_to}__apx-#{apixel_from}-#{apixel_to}"
	altfilename = "./#{GS[:visual_dir]}/#{settings[:name]}/#{px_in_name}__addr-%0#{2*GS[:addr_len]}x-%0#{2*GS[:addr_len]}x.alt" % [addr_from, addr_to]
	alt_to_file(mask, altfilename)
	altfiles << altfilename
	
	previewfile = gen_view(txt_file, addr_from, addr_to, row_from, row_to, 1, nil, nil).first
	i += 1
	
	if File.basename(previewfile) == File.basename(png_file)
		FileUtils.cp previewfile, "./#{GS[:visual_dir]}/#{settings[:name]}/%02d.png" % [i]
	else
		FileUtils.mv previewfile, "./#{GS[:visual_dir]}/#{settings[:name]}/%02d.png" % [i]
	end
	pngfiles << "./#{GS[:visual_dir]}/#{settings[:name]}/%02d.png" % [i]
	
	puts "\nCheck #{"%02d.png" % [i]}, if it is OK, use #{altfilename} as altfile for next step."
	print "Start filtering with this range? (Y/n) "
end until $stdin.gets.chomp == "Y"

FileUtils.rm altfiles.to_a.select{|f|f != altfilename}
FileUtils.rm pngfiles.to_a

# copy binary traces
target_dir = "#{GS[:traces_dir]}/#{settings[:name]}__#{px_in_name}"
FileUtils.rm_rf(target_dir, secure: true)
FileUtils.mkdir(target_dir)
FileUtils.cp(Dir["#{GS[:traces_dir]}/#{settings[:name]}/*"], target_dir)

# use altfilename
filter(Dir["#{target_dir}/*"], alt_from_file(altfilename), :bin)
