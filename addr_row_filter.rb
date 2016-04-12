#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ ./#{File.basename(__FILE__)} <name>

") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

# run interactive visual range filtering & save final ranges into settings
last_png = range_filtering(settings, false)

# copy traces
FileUtils.cp(Dir["#{settings.bin_traces_dir}/*"], settings.bin_flt_traces_dir)
FileUtils.cp(settings.txt_trace, settings.flt_txt_trace)
FileUtils.cp(last_png, settings.flt_png_preview)

# apply range filter
mask = mask_from_file(settings.range_filter_file)
filter(Dir["#{settings.bin_flt_traces_dir}/*"], mask, :bin)
filter([settings.flt_txt_trace], mask, :txt)

# rename traces & save settings
FileUtils.mv settings.flt_txt_trace, "#{File.dirname settings.flt_txt_trace}/#{File.basename(settings.flt_txt_trace, ".rge")}"
FileUtils.mv "#{settings.flt_txt_trace}.flt", settings.flt_txt_trace
save_settings(settings)

# next steps
puts "
You can find filtered traces in
	'#{settings.bin_flt_traces_dir}'"

tell_attack_all_bytes(settings)
puts
