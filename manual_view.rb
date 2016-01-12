#!/usr/bin/env ruby

require "./tools/all.rb"

$stderr.puts("Usage:
	$ #{File.basename(__FILE__)} file (
		1:dec_split_files
		2:hex_addr_from
		3:hex_addr_to
		4:dec_line_from
		5:dec_line_to
		6:hex_rows_per_pixel
		7:hex_addrs_per_pixel
	  )") or exit if ARGV[0].nil?

filename = ARGV[0]

ADDR_FROM = ARGV[3].nil? ? 0 : ARGV[2].hex   # either none or both must be set
ADDR_TO = ARGV[3].nil? ? 0xffffffffffff : ARGV[3].hex

LINE_FROM = ARGV[4].nil? ? 0 : ARGV[4].to_i
LINE_TO = ARGV[5].nil? ? Float::INFINITY : (ARGV[5].to_i == -1 ? Float::INFINITY : ARGV[5].to_i)

SPLIT_FILES = ARGV[1].nil? ? 16 : ARGV[1].to_i
ROW_DIV_ARG = ARGV[6]
ADDR_DIV_ARG = ARGV[7]

puts "Settings:\n\tAddress from: #{"%x" % ADDR_FROM}\n\tAddress to:   #{"%x" % ADDR_TO}\n\tLine from: #{LINE_FROM}\n\tLine to:   #{LINE_TO}\n\tSplit files: #{SPLIT_FILES}"

gen_view(filename, ADDR_FROM, ADDR_TO, LINE_FROM, LINE_TO, SPLIT_FILES, ROW_DIV_ARG, ADDR_DIV_ARG)