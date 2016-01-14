#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("Usage:
	$ #{File.basename(__FILE__)} name") or exit if ARGV[0].nil?

settings = load_settings(ARGV[0])


fltfile = Dir["#{GS[:visual_dir]}/#{settings[:name]}/*.flt"].select{|f|f =~ /[0-9a-fA-F]{32}\.flt/}.first
$stderr.puts("Fatal: no *.flt file found! (in \"#{GS[:visual_dir]}/#{settings[:name]}\")") or exit if fltfile.nil?
pngfile = Dir["#{GS[:visual_dir]}/#{settings[:name]}/*"].select{|f|f =~ /[0-9a-fA-F]{32}\.flt__[0-9a-fA-F]{12}\-\-[0-9a-fA-F]{12}__[0-9]+?x[0-9]+?\.png/}.first
$stderr.puts("Fatal: no *.png file found! (in \"#{GS[:visual_dir]}/#{settings[:name]}\")") or exit if pngfile.nil?

puts "Previously you have checked
	#{pngfile}."

addr_beg = pngfile.match(/__[0-9a-fA-F]{12}\-\-[0-9a-fA-F]{12}__[0-9]+?x[0-9]+?\.png/).to_s.split("--")[0][2..-1].hex
addr_div = pngfile.match(/__[0-9]+?x[0-9]+?\.png/).to_s.split("x")[1].split(".")[0].to_i
row_div = pngfile.match(/__[0-9]+?x[0-9]+?\.png/).to_s.split("x")[0][2..-1].to_i

FileUtils.rm_rf("#{GS[:visual_dir]}/#{settings[:name]}/#{GS[:arf_dir]}", secure: true)
FileUtils.mkpath("#{GS[:visual_dir]}/#{settings[:name]}/#{GS[:arf_dir]}")
FileUtils.cp(fltfile, "#{GS[:visual_dir]}/#{settings[:name]}/#{GS[:arf_dir]}/")
fltfile = File.basename fltfile

px_in_name = nil
altfilename = nil

Dir.chdir("#{GS[:visual_dir]}/#{settings[:name]}/#{GS[:arf_dir]}") do
	i = 0
	begin
		i += 1
		puts "Now provide desired address/row range in pixels from left/top."
		
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
		
		mask = File.read(fltfile).split("\n").map.with_index do |line,row|
			addr = line.split[1].hex
			addr >= addr_from and addr <= addr_to and row >= row_from and row <= row_to
		end
		
		px_in_name = "rpx-#{rpixel_from}-#{rpixel_to}__apx-#{apixel_from}-#{apixel_to}"
		altfilename = "#{px_in_name}__addr-%0#{2*GS[:addr_len]}x-%0#{2*GS[:addr_len]}x.alt" % [addr_from, addr_to]
		alt_to_file(mask, altfilename)
		
		previewfile = gen_view(fltfile, addr_from, addr_to, row_from, row_to, 1, nil, nil).first
		FileUtils.mv previewfile, "%02d.png" % [i]
		
		print "\nCheck \"#{GS[:visual_dir]}/#{settings[:name]}/#{GS[:arf_dir]}/#{"%02d.png" % [i]}\".
Start filtering with this range? (Y/n) "
	end until $stdin.gets.chomp == "Y"
end

# copy binary traces
target_dir = "#{GS[:traces_dir]}/#{settings[:name]}__#{px_in_name}"
FileUtils.rm_rf(target_dir, secure: true)
FileUtils.mkpath(target_dir)
FileUtils.cp(Dir["#{GS[:traces_dir]}/#{settings[:name]}/*"], target_dir)

# use altfilename
filter(Dir["#{target_dir}/*"], alt_from_file("#{GS[:visual_dir]}/#{settings[:name]}/#{GS[:arf_dir]}/#{altfilename}"), :bin)

puts "\nYou can find filtered traces in \"#{target_dir}\". Now run attack
	$ cd ../cpp_attack
	$ ./attack copy_template_and_fill_own_settings.yaml"
