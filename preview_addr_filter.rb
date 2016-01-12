#!/usr/bin/env ruby

require "fileutils"
require "./tools/all.rb"

$stderr.puts("Usage:
	$ #{File.basename(__FILE__)} name pixel_from pixel_to flt/orig") or exit if ARGV[3].nil?

NAME = ARGV[0]
PIXEL_FROM = ARGV[1].to_i
PIXEL_TO = ARGV[2].to_i
FO = [:flt, :orig].include?(ARGV[3].to_sym) ? ARGV[3].to_sym : ($stderr.puts("Invalid flt/orig.") or exit)

$stderr.puts("Address from must be smaller than address to.") or exit unless PIXEL_FROM < PIXEL_TO

TXT_FILE = {}
TXT_FILE[:flt] = Dir["#{VISUAL_DIR}/*.flt"].select{|f|f =~ /#{NAME}_[0-9a-fA-F]{32}\.flt/}.first
TXT_FILE[:orig] = Dir["#{VISUAL_DIR}/*.orig"].select{|f|f =~ /#{NAME}_[0-9a-fA-F]{32}\.orig/}.first
PNG_FILE = Dir["#{VISUAL_DIR}/*.png"].select{|f|f =~ /#{NAME}_[0-9a-fA-F]{32}\.#{FO}__/}.first
addr_beg = PNG_FILE.match(/__[0-9a-fA-F]{12}\-\-[0-9a-fA-F]{12}__[0-9]+?x[0-9]+?\.png/).to_s.split("--")[0][2..-1].hex
addr_div = PNG_FILE.match(/__[0-9]+?x[0-9]+?\.png/).to_s.split("x")[1].split(".")[0].to_i
ADDR_FROM = addr_beg + PIXEL_FROM * addr_div
ADDR_TO = addr_beg + PIXEL_TO * addr_div

mask = File.read(TXT_FILE[:flt]).split("\n").map do |line|
	addr = line.split[1].hex
	addr >= ADDR_FROM and addr <= ADDR_TO
end

altfilename = "./#{VISUAL_DIR}/#{NAME}__%0#{2*ADDR_LEN}x--%0#{2*ADDR_LEN}x.alt" % [ADDR_FROM, ADDR_TO]
alt_to_file(mask, altfilename)

previewfiles = gen_view(TXT_FILE[FO], ADDR_FROM, ADDR_TO, 0, Float::INFINITY, 1, nil, nil)

puts "\nCheck #{previewfiles[0]}, if it is OK, use #{altfilename} as altfile for next step."