#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("Usage:
	$ #{File.basename(__FILE__)} ra/rc/wa/wc \"AES command\" row_with_ciphertext name (n_traces = 32)
		where
			ra ... Read  Address#{GS.has_key?(:acq_ra) ? "" : ", not implemented yet"},
			rc ... Read  Content#{GS.has_key?(:acq_rc) ? "" : ", not implemented yet"},
			wa ... Write Address#{GS.has_key?(:acq_wa) ? "" : ", not implemented yet"},
			wc ... Write Content#{GS.has_key?(:acq_wc) ? "" : ", not implemented yet"}.") or exit if ARGV[2].nil?

# check ASLR OFF
$stderr.print("Is ASLR really OFF? (Y/n) ")
isoff = $stdin.gets.chomp
$stderr.puts("Consider
	$ setarch `uname -m` -R /bin/bash") or exit unless isoff == "Y"

# read arguments & set parameters
settings = {}
settings[:acq] = case ARGV[0]
when "ra"
	GS.has_key?(:acq_ra) ? GS[:acq_ra] : ($stderr.puts("Read Address has not been implemented yet.") or exit)
when "rc"
	GS.has_key?(:acq_rc) ? GS[:acq_rc] : ($stderr.puts("Read Content has not been implemented yet.") or exit)
when "wa"
	GS.has_key?(:acq_wa) ? GS[:acq_wa] : ($stderr.puts("Write Address has not been implemented yet.") or exit)
when "wc"
	GS.has_key?(:acq_wc) ? GS[:acq_wc] : ($stderr.puts("Write Content has not been implemented yet.") or exit)
else
	$stderr.puts("Invalid first argument.") or exit
end
settings[:cmd] = ARGV[1]
settings[:ct_row] = ARGV[2].to_i
settings[:name] = ARGV[3]
settings[:n_traces] = ARGV[4].nil? ? 10 : ARGV[4].to_i
settings[:ndots] = settings[:n_traces] < GS[:ndots_default] ? settings[:n_traces] : GS[:ndots_default]


# acquire & save traces
sample_pt, merge = get_traces(settings)

# create & use & save mask of alternating bytes of traces (non-constant ones)
alt = alt_mask(settings)
filter(Dir["#{GS[:traces_dir]}/#{settings[:name]}/*"], alt, :bin, true)
alt_to_file(alt, "#{GS[:traces_dir]}/#{settings[:name]}.alt")

# merge traces if told to
merge_traces(settings) if merge

# acquire sample pt again to text & create preview
tp = trace_preview(settings, sample_pt, alt)

# save settings
save_settings(settings, merge)

puts "
Have a look at trace preview in
	\"#{tp}\".
If you are sure where encryption takes place, filter address & row range by
	$ ./#{MANFLT_FILE} #{settings[:name]}
If you want to split or zoom the memtrace figure, run
	$ ./#{MANVIEW_FILE} #{settings[:name]}
If you are not sure you can attack first 1..3 bytes and find the place of encryption, run
	$ ./#{ATTACK_FILE} #{settings[:name]} (n_traces=-1 bytes=16)"
