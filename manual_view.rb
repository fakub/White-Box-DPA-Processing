#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("Usage:
	$ #{File.basename(__FILE__)} name") or exit if ARGV[0].nil?

settings = load_settings(ARGV[0])


fltfile = Dir["#{GS[:visual_dir]}/#{settings[:name]}/*.flt"].first   #!# check
$stderr.puts("Fatal: no *.flt file found! (in \"#{GS[:visual_dir]}/#{settings[:name]}\")") or exit if fltfile.nil?
FileUtils.rm_rf("#{GS[:visual_dir]}/#{settings[:name]}/#{GS[:man_view_dir]}", secure: true)
FileUtils.mkpath("#{GS[:visual_dir]}/#{settings[:name]}/#{GS[:man_view_dir]}")
FileUtils.cp(fltfile, "#{GS[:visual_dir]}/#{settings[:name]}/#{GS[:man_view_dir]}/")
fltfile = File.basename fltfile

addr_from = nil
addr_to = nil
line_from = nil
line_to = nil
split_files = nil
row_div_arg = nil
addr_div_arg = nil

Dir.chdir("#{GS[:visual_dir]}/#{settings[:name]}/#{GS[:man_view_dir]}") do
	last_views = []
	
	puts "All values can be set to default by simply hitting Enter."
	
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
		print "Row div (dangerous, dec): "
		row_div_arg = $stdin.gets.to_i.abs
		row_div_arg = row_div_arg == 0 ? nil : row_div_arg
		print "Address div (dangerous, dec): "
		addr_div_arg = $stdin.gets.to_i.abs
		addr_div_arg = addr_div_arg == 0 ? nil : addr_div_arg
		
		last_views << gen_view(fltfile, addr_from, addr_to, line_from, line_to, split_files, row_div_arg, addr_div_arg)
		
		puts "\nCheck files in \"#{GS[:visual_dir]}/#{settings[:name]}/#{GS[:man_view_dir]}\"."
		print "Enough? (Y/n) "
	end until $stdin.gets.chomp == "Y"
end

puts "
Final settings:
	Address from: 0x#{addr_from.to_s 16}
	Address to: 0x#{addr_to.to_s 16}
	Line from: #{line_from}
	Line to: #{line_to}
	Split files: #{split_files}
	Row div: #{row_div_arg}
	Address div: #{addr_div_arg}

If you are sure where encryption takes place, filter address & row range by
	$ ./#{MANFLT_FILE} #{settings[:name]}
If you are not sure you can attack first 1..3 bytes and find the place of encryption, run
	$ ./#{ATTACK_FILE} #{settings[:name]} (n_traces=-1 bytes=16)"
