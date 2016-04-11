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
If you are not sure, you can attack first 1..3 bytes and find the place of encryption, run
	$ ./#{ATTACK_FILE} #{settings[:name]} -1 0
	    #{" " * ATTACK_FILE.size} #{" " * settings[:name].size}    ^ key byte
	    #{" " * ATTACK_FILE.size} #{" " * settings[:name].size}  ^   number of traces (-1 ~ all)
and
	$ ./#{MARK_ENCR_FILE} #{settings[:name]}"
end

def tell_attack_all_bytes(settings)
	puts "Run attack
	$ for i in {0..15}; \\
	$ do ./#{ATTACK_FILE} #{settings[:name]} -1 $i; \\
	$ done
	       #{" " * ATTACK_FILE.size} #{" " * settings[:name].size}    ^ key byte
	       #{" " * ATTACK_FILE.size} #{" " * settings[:name].size}  ^   number of traces (-1 ~ all)

"

end