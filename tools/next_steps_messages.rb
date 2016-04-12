# keep all possibly repeating messages at one place

def tell_start
	puts "
---===###   Welcome!   ###===---

Copy '#{GS_TEMPL_FILE}' into '#{GS_FILE}' and customize settings.
Then start with
	$ ./#{ACQ_FILE}"
end

def tell_filter_ranges(settings)
	puts "
If you are sure where encryption takes place, filter address & row range by
	$ ./#{MANFLT_FILE} #{settings[:name]}"
end

def tell_manual_view(settings)
	puts "
If you want to split or zoom the memtrace figure, run
	$ ./#{MANVIEW_FILE} #{settings[:name]}"
end

def tell_attack_first_bytes(settings)
	puts "
If you are not sure, you can find where encryption takes place:
	1) attack first 1..3 bytes,
	2) process results,
	3) display results & find the best target (and target bit if applicable), and
	4) emphasize leakage position.

Attack first 1..3 bytes
	$ ./#{ATTACK_FILE} #{settings[:name]} <attack_name> [-1 0 0x1f 2b7e...]
	                  #{" " * ATTACK_FILE.size} #{" " * settings[:name].size}            ^ expected key
	                  #{" " * ATTACK_FILE.size} #{" " * settings[:name].size}       ^      attack target (all/0x??)
	                  #{" " * ATTACK_FILE.size} #{" " * settings[:name].size}     ^        key byte
	                  #{" " * ATTACK_FILE.size} #{" " * settings[:name].size}   ^          number of traces (-1 ~ all)"
	tell_results_process(settings)
	tell_results_disp(settings)
	puts "
Emphasize leakage position
	$ ./#{MARK_ENCR_FILE} #{settings[:name]} <attack_name> [-1 0 0b00000001 0]
	                  #{" " * MARK_ENCR_FILE.size} #{" " * settings[:name].size}                  ^ target bit (if applicable)
	                  #{" " * MARK_ENCR_FILE.size} #{" " * settings[:name].size}       ^            target (0x??/0b??...)
	                  #{" " * MARK_ENCR_FILE.size} #{" " * settings[:name].size}     ^              key byte (0..15)
	                  #{" " * MARK_ENCR_FILE.size} #{" " * settings[:name].size}   ^                number of traces (-1 ~ all)"
end

def tell_attack_all_bytes(settings)
	puts "
Run attack
	$ for i in {0..15}; \\
	$ do ./#{ATTACK_FILE} #{settings[:name]} <attack_name> [-1 $i 0x1f 2b7e...]; \\
	$ done
	                     #{" " * ATTACK_FILE.size} #{" " * settings[:name].size}             ^ expected key
	                     #{" " * ATTACK_FILE.size} #{" " * settings[:name].size}        ^      attack target (all/0x??)
	                     #{" " * ATTACK_FILE.size} #{" " * settings[:name].size}     ^         key byte (0..15)
	                     #{" " * ATTACK_FILE.size} #{" " * settings[:name].size}   ^           number of traces (-1 ~ all)"
end

def tell_results_process(settings, attn = "<attack_name>")
	puts "
Finished attacking? Process results
	$ ./#{RES_PROC_FILE} #{settings[:name]} #{attn}"
end

def tell_results_disp(settings, attn = "<attack_name>")
	puts "
Display results
	$ ./#{RES_DISP_FILE} #{settings[:name]} #{attn}"
end

def tell_the_end
	puts "
---===###   The End!   ###===---"
end
