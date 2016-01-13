#!/usr/bin/env ruby

require "./tools/all.rb"

$stderr.puts("Usage:
	$ #{File.basename(__FILE__)} name") or exit if ARGV[0].nil?

# read arguments & set parameters
settings = {}
settings[:name] = ARGV[0]

filename = Dir["#{GS[:visual_dir]}/#{settings[:name]}/*.flt"].first
FileUtils.rm_rf("#{GS[:visual_dir]}/#{settings[:name]}/playground", secure: true)
FileUtils.mkdir("#{GS[:visual_dir]}/#{settings[:name]}/playground")
last_views = []

begin
	FileUtils.rm last_views
	last_views = []
	
	begin
		print "Address from (hex): "
		addr_from = $stdin.gets.hex.abs
		print "Address to (hex):   "
		addr_to = $stdin.gets.hex
		addr_to = (addr_to <= 0) ? 0xffffffffffff : addr_to
	end until addr_from < addr_to or $stderr.puts("Address from must be smaller than Address to. Use 0 instead of 0xffffffffffff.")
	begin
		print "Line from (dec): "
		line_from = $stdin.gets.to_i.abs
		print "Line to (dec):   "
		line_to = $stdin.gets.to_i
		line_to = (line_to <= 0) ? Float::INFINITY : line_to
	end until line_from < line_to or $stderr.puts("Line from must be smaller than Line to. Use 0 instead of INFINITY.")
	print "Split files: "
	split_files = $stdin.gets.to_i
	split_files = (split_files <= 0) ? 1 : split_files
	print "Row div (optional, dec): "
	row_div_arg = $stdin.gets.to_i.abs
	row_div_arg = row_div_arg == 0 ? nil : row_div_arg
	print "Address div (optional, dec): "
	addr_div_arg = $stdin.gets.to_i.abs
	addr_div_arg = addr_div_arg == 0 ? nil : addr_div_arg
	
	#!# may rewrite original trace preview !!!
	lv = gen_view(filename, addr_from, addr_to, line_from, line_to, split_files, row_div_arg, addr_div_arg)
	lv.each do |file|
		FileUtils.mv(file, "#{GS[:visual_dir]}/#{settings[:name]}/playground/" + File.basename(file))
		last_views << "#{GS[:visual_dir]}/#{settings[:name]}/playground/" + File.basename(file)
	end
	
	puts "\nCheck files in #{GS[:visual_dir]}/#{settings[:name]}/playground/."
	print "Enough? (Y/n) "
end until $stdin.gets.chomp == "Y"

puts "Final settings:
	Address from: 0x#{addr_from.to_s 16}
	Address to: 0x#{addr_to.to_s 16}
	Line from: #{line_from}
	Line to: #{line_to}
	Split files: #{split_files}
	Row div: #{row_div_arg}
	Address div: #{addr_div_arg}

If you are sure where encryption takes place, filter address & row range by
	$ ./addr_row_filter.rb #{settings[:name]}
Otherwise you need to attack first 1-3 bytes and find the place of encryption, run
	$ ./???"