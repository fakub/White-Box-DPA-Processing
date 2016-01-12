#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("Usage:
	$ #{File.basename(__FILE__)} ra/rc/wa/wc \"AES command\" row_with_ciphertext name (n_traces = 32)
		where
			ra ... Read Address,
			rc ... Read Content, not implemented yet,
			wa ... Write Address, not implemented yet,
			wc ... Write Content ") or exit if ARGV[2].nil?

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
sample_pt = get_traces(settings)

# create & use & save mask of alternating bytes of traces (non-constant ones)
alt = alt_mask(settings)
filter(Dir["#{GS[:traces_dir]}/#{settings[:name]}/*"], alt, :bin, true)
alt_to_file(alt, "#{GS[:traces_dir]}/#{settings[:name]}.alt")

# acquire sample pt again to text & create preview
trace_preview(settings, sample_pt, alt)

puts "\nContinue with
	$ ./addr_filter.rb #{settings[:name]}"
