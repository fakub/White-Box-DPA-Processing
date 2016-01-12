#!/usr/bin/env ruby

require "open3"
require "fileutils"
require "./tools/all.rb"

# print help
$stderr.puts("Usage:
	$ #{File.basename(__FILE__)} ra/(rc)/(wa)/wc \"AES command\" row_with_ciphertext name (n_traces = 32)
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
	{bin: "../pin-2.14-71313-gcc.4.4.7-linux/pin -t ../pin-2.14-71313-gcc.4.4.7-linux/source/tools/MemoryTracer/obj-intel64/TracerByTeuwen_read_addr.so --",
	txt: "../pin-2.14-71313-gcc.4.4.7-linux/pin -t ../pin-2.14-71313-gcc.4.4.7-linux/source/tools/MemoryTracer/obj-intel64/MemoryTracer_read_addr.so --"}
when "rc"
	$stderr.puts("Read Content has not been implemented yet.") or exit
when "wa"
	$stderr.puts("Write Address has not been implemented yet.") or exit
when "wc"
	{bin: "../pin-2.14-71313-gcc.4.4.7-linux/pin -t ../pin-2.14-71313-gcc.4.4.7-linux/source/tools/MemoryTracer/obj-intel64/TracerByTeuwen.so --",
	txt: "../pin-2.14-71313-gcc.4.4.7-linux/pin -t ../pin-2.14-71313-gcc.4.4.7-linux/source/tools/MemoryTracer/obj-intel64/MemoryTracer.so --"}
else
	$stderr.puts("Invalid first argument.") or exit
end
settings[:cmd] = ARGV[1]
settings[:ct_row] = ARGV[2].to_i
settings[:name] = ARGV[3]
settings[:n_traces] = ARGV[4].nil? ? 10 : ARGV[4].to_i
settings[:ndots] = settings[:n_traces] < NDOTS_DEFAULT ? settings[:n_traces] : NDOTS_DEFAULT


# acquire & save traces
sample_pt = get_traces(settings)

# create & use & save mask of alternating bytes of traces (non-constant ones)
alt = alt_mask(settings)
filter(Dir["#{TRACES_DIR}/#{settings[:name]}/*"], alt, :bin, true)
alt_to_file(alt, "#{TRACES_DIR}/#{settings[:name]}.alt")

# acquire sample pt again to text & create preview
trace_preview(settings, sample_pt, alt)

