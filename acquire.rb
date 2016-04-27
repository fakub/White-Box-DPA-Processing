#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ ./#{File.basename(__FILE__)} <attack_settings.yaml>

Copy '#{SETT_TEMPL_FILE}', modify the settings and run again with your settings file.

") or exit if ARGV[0].nil?

# generate settings from argument
settings = gen_settings(ARGV[0])

# check ASLR, is it OFF?
$stderr.print("
Is ASLR really OFF? (Y/n) ")
isoff = $stdin.gets.chomp
$stderr.puts("
Consider
	$ setarch `uname -m` -R /bin/bash

") or exit unless isoff == "Y"


# handle existing name (ask user)
merge = handle_existing_name(settings)

# acquire, filter & save traces
get_bin_traces(settings, merge)

# merge traces if told to
merged = merge_traces(settings) if merge

# acquire sample pt again to text & create preview
unless merge and merged
	get_txt_trace(settings)
	begin
		settings[:png_filename] = File.basename gen_view(settings.txt_trace, 0, Float::INFINITY, 0, Float::INFINITY, 1, nil, nil).first
		settings[:addr_beg] = addr_begin(settings[:png_filename])
		settings[:addr_div] = addr_div(settings[:png_filename])
		settings[:row_div] = row_div(settings[:png_filename])
	rescue
		settings[:png_filename] = ""
		settings[:addr_beg] = ""
		settings[:addr_div] = ""
		settings[:row_div] = ""
	end
end

# save settings
save_settings(settings)


# next steps
puts "
Have a look at a trace preview in
	'#{settings.png_preview}'"

tell_manual_view(settings)
tell_filter_ranges(settings)
tell_attack_first_bytes(settings)
puts
