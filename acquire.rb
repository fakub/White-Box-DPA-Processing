#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ #{File.basename(__FILE__)} attack_settings.yaml

Copy attack_settings.yaml.template and modify the settings.") or exit if ARGV[0].nil?

# generate settings
settings = gen_settings(ARGV[0])

# check ASLR OFF
$stderr.print("Is ASLR really OFF? (Y/n) ")
isoff = $stdin.gets.chomp
$stderr.puts("Consider
	$ setarch `uname -m` -R /bin/bash") or exit unless isoff == "Y"


# handle existing name
merge = handle_existing_name(settings)

# acquire, filter & save traces
get_bin_traces(settings, merge)

# merge traces if told to
merged = merge_traces(settings) if merge

# acquire sample pt again to text & create preview
unless merge and merged
	get_txt_trace(settings)
	settings[:png_filename] = File.basename gen_view(settings.txt_trace, 0, Float::INFINITY, 0, Float::INFINITY, 1, nil, nil).first
	settings[:addr_beg] = addr_begin(settings[:png_filename])
	settings[:addr_div] = addr_div(settings[:png_filename])
	settings[:row_div] = row_div(settings[:png_filename])
end

# save settings
save_settings(settings)

puts "
Have a look at a trace preview in
	\"#{settings.png_preview}\".
If you are sure where encryption takes place, filter address & row range by
	$ ./#{MANFLT_FILE} #{settings[:name]}
If you want to split or zoom the memtrace figure, run
	$ ./#{MANVIEW_FILE} #{settings[:name]}
If you are not sure you can attack first 1..3 bytes and find the place of encryption, run
	$ ./#{ATTACK_FILE} #{settings[:name]} (n_traces=-1 bytes=16)"
