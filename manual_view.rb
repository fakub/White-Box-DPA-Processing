#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ ./#{File.basename(__FILE__)} name

") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

# run interactive visual range filtering & save final ranges into settings
range_filtering(settings, true)

puts "
Final settings:
	Address from: #{settings[:apixel_from]}
	Address to: #{settings[:apixel_to]}
	Row from: #{settings[:rpixel_from]}
	Row to: #{settings[:rpixel_to]}
	Split files: #{settings[:split_files]}
	Row div: #{settings[:row_div_arg]}
	Address div: #{settings[:addr_div_arg]}"

tell_filter_ranges(settings)
tell_attack_first_bytes(settings)
puts
