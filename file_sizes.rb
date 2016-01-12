#!/usr/bin/env ruby

require "fileutils"

$stderr.puts("Usage:
	$ #{File.basename(__FILE__)} dir_name") or exit if ARGV[0].nil?

DIR_NAME = ARGV[0]

files = Dir["#{DIR_NAME}/*"]
files.each do |file|
	next if File.directory? file
	puts ("%16s ... " % (File.basename(file)[0..15])) + File.size(file).to_s
end