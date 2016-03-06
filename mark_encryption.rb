#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ #{File.basename(__FILE__)} name (n_traces=-1 bytes=16 hypothesis=sbox/rijinv/lin expected_key=2b7e151628aed2a6abf7158809cf4f3c)

where
	rijinv stands for Rijndael inverse, and
	expected_key can be partial.") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

# load results


# find leakage
#~ log = log.split(/Attacking[\W]+?[\d]+?\.\Wbyte\W\.\.\./)
#~ log.slice!(0)
#~ 
#~ argmax = []
#~ 
#~ log.each do |lb|
	#~ argmax << lb.split("New local max: ").last.split(/\n/)[2].split("|")[3].to_i
#~ end
#~ 
#~ addr_beg = settings[:addr_beg]
#~ addr_div = settings[:addr_div]
#~ row_div = settings[:row_div]
#~ 
#~ addrrows = []
#~ emphed = "#{settings.traces_dir}/emph.png"
#~ FileUtils.cp settings.png_preview, emphed
#~ mask = mask_from_file(settings.range_filter_file) if settings.attack_range_flt
#~ 
#~ argmax.each do |pos|
	#~ pos /= 8
	#~ if settings.attack_range_flt
		#~ cnt = 0
		#~ mask.each.with_index do |tf,i|
			#~ next unless tf
			#~ (cnt = i and break) if cnt == pos
			#~ cnt += 1
		#~ end
		#~ pos = cnt
	#~ end
	#~ 
	#~ addrrows << [IO.readlines(settings.txt_trace)[pos].split[1].hex, pos]
	#~ 
	#~ apixel = (addrrows.last[0] - addr_beg) / addr_div
	#~ rpixel = pos / row_div
	#~ 
	#~ emph_in_image(apixel, rpixel, 120, emphed)
#~ end
#~ 
#~ leak_log = "
#~ o==============================================================================o
#~ | With plaintext #{settings[:sample_pt]}, it leaks at:                |
#~ #{addrrows.map{|addr,row|"|   0x" + addr.to_s(16) + " (at row " + row.to_s + ")" + " "*(63-addr.to_s(16).length-row.to_s.length)}.join("|\n")}|
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
