#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ ./#{File.basename(__FILE__)} name attack_name [-1 0 0b00000001 0]

where
	        -1 ... number of traces, -1 ~ all
	         0 ... key byte, from range 0..15
	0b00000001 ... successful target
	         0 ... target bit (if applicable)

") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

arg_attn = ARGV[1]
arg_ntr = ARGV[2]
arg_byte = ARGV[3]
arg_target = ARGV[4]
arg_tbit = ARGV[5]

# set number of traces
n_traces = (arg_ntr.to_i <= 0) ? settings[:n_traces] : arg_ntr.to_i
# set attacked key byte
attack_byte = (0..15).include?(arg_byte.to_i) ? arg_byte.to_i : 0
# set attack target
target = arg_target.nil? ? "0b00000001" : arg_target
# set target bit
tbit = (0..7).include?(arg_tbit.to_i) ? arg_tbit.to_i : 0

# load results
filename = "#{settings.attack_dir}/#{arg_attn}/#{n_traces}_#{attack_byte}_#{target}.yaml"
raise "Results do not exist!" unless File.exists? filename
position = YAML.load(File.read filename)[tbit].first[2]

# emphasize
addr_beg = settings[:addr_beg]
addr_div = settings[:addr_div]
row_div = settings[:row_div]

emphed = "#{settings.traces_dir}/emph.png"
FileUtils.cp settings.png_preview, emphed
mask = mask_from_file(settings.range_filter_file) if settings.attack_range_flt

position /= 8
if settings.attack_range_flt
	cnt = 0
	mask.each.with_index do |tf,i|
		next unless tf
		(cnt = i and break) if cnt == position
		cnt += 1
	end
	position = cnt
end

addrrow = [IO.readlines(settings.txt_trace)[position].split[1].hex, position]

apixel = (addrrow[0] - addr_beg) / addr_div
rpixel = position / row_div

emph_in_image(apixel, rpixel, 120, emphed)

puts "
See
	'#{emphed}'

"

#~ 
#~ leak_log = "
#~ o==============================================================================o
#~ | With plaintext #{settings[:sample_pt]}, it leaks at:                |
#~ |   0x" + addrrow[0].to_s(16) + " (at row " + addrrow[1].to_s + ")" + " "*(63-addrrow[0].to_s(16).length-addrrow[1].to_s.length)|
#~ o==============================================================================o"
#~ 
#~ puts leak_log

#~ puts "
#~ Check a readable log in
	#~ \"#{log_filename}\", or
#~ a YAML file with full results in
	#~ \"#{res_filename}\"
#~ to see how strong the candidates are.
#~ If OK, see \"#{emphed}\", this is where encryption probably takes place.
#~ You can filter address & row range by
	#~ $ ./#{MANFLT_FILE} #{settings[:name]}
#~ If the attack was successful, you can exploit leaking addresses to find out where the implementation leaks (e.g. in GDB)."

# former C++ output (nice)

#~ bool eq = true;
#~ 
#~ fprintf(stderr, "o==============================================================================o\n");
#~ fprintf(stderr, "| Expected:  ");   printnbytes(exp_key, 16, "  ");        fprintf(stderr, "    |\n");
#~ fprintf(stderr, "| Got:       ");   printnbytes(bestguess, 16,  "  ");     fprintf(stderr, "    |\n");
#~ fprintf(stderr, "|            ");
#~ for (int i=0; i<16; i++)
	#~ if (exp_key[i] != bestguess[i]) {
		#~ fprintf(stderr, " ^  ");
		#~ eq = false;
	#~ } else fprintf(stderr, "    ");
#~ fprintf(stderr, "  |\n");
#~ if (eq) {
	#~ fprintf(stderr, "|                   Congrats! The key has been broken!                         |\n");
#~ } else {
	#~ fprintf(stderr, "| Diff:     "); char buff[] = "12345";
	#~ for (byte i=0; i<16; i++) {
		#~ sprintf(buff, "%0.3f", maxdiffs[i]);
		#~ fprintf(stderr, "%s", buff+1);
	#~ }
	#~ fprintf(stderr, "   |\n");
#~ }
#~ fprintf(stderr, "o==============================================================================o\n\n");
