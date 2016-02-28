#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ #{File.basename(__FILE__)} name") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

# run visual range filtering & save final ranges into settings
range_filtering(settings, true)

puts "
Final settings:
	Address from: #{settings[:apixel_from]}
	Address to: #{settings[:apixel_to]}
	Row from: #{settings[:rpixel_from]}
	Row to: #{settings[:rpixel_to]}
	Split files: #{settings[:split_files]}
	Row div: #{settings[:row_div_arg]}
	Address div: #{settings[:addr_div_arg]}

If you are sure where encryption takes place, filter address & row range by
	$ ./#{MANFLT_FILE} #{settings[:name]}
If you are not sure you can attack first 1..3 bytes and find the place of encryption, run
	$ ./#{ATTACK_FILE} #{settings[:name]} (n_traces=-1 bytes=16)"
