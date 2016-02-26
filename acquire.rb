#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ #{File.basename(__FILE__)} attack_settings.yaml

Copy attack_settings.yaml.template and modify the settings.") or exit if ARGV[0].nil?

# load & generate settings
settings = gen_settings(ARGV[0])

# check ASLR OFF
$stderr.print("Is ASLR really OFF? (Y/n) ")
isoff = $stdin.gets.chomp
$stderr.puts("Consider
	$ setarch `uname -m` -R /bin/bash") or exit unless isoff == "Y"


# acquire & save traces
#~ sample_pt, merge = get_traces(settings)
sample_pt = get_traces(settings)

# create & use & save mask of alternating bytes of traces (non-constant ones)
alt = alt_mask(settings[:traces_dir])
filter(Dir["#{settings[:traces_dir]}/*"], alt, :bin, true)
alt_to_file(alt, settings[:const_filter_file])

# merge traces if told to
#~ merge_traces(settings) if merge

# acquire sample pt again to text & create preview
tp = trace_preview(settings, sample_pt, alt)

# save settings
#~ save_settings(settings, merge)
save_settings(settings)

puts "
Have a look at trace preview in
	\"#{tp}\".
If you are sure where encryption takes place, filter address & row range by
	$ ./#{MANFLT_FILE} #{settings[:name]}
If you want to split or zoom the memtrace figure, run
	$ ./#{MANVIEW_FILE} #{settings[:name]}
If you are not sure you can attack first 1..3 bytes and find the place of encryption, run
	$ ./#{ATTACK_FILE} #{settings[:name]} (n_traces=-1 bytes=16)"
