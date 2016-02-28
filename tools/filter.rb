def mask_from_file(file)
	File.read(file).scan(/./).map{|c|c == "1"}
end

def mask_to_file(mask, file)
	File.write(file, mask.map{|b|b ? "1" : "0"}.join)
end

def filter(all_files, alt, mode, verbose = false)
	$stderr.puts("Invalid mode in filter method.") or exit unless [:bin, :txt].include? mode
	
	n_traces = all_files.size
	ndots = n_traces < GS[:n_dots_default] ? n_traces : GS[:n_dots_default]
	
	if verbose
		puts "\nFiltering traces ..."
		puts "_" * ndots
	end
	doti = 0
	
	if mode == :bin
		all_files.each_with_index do |file,i|
			if verbose and i*ndots >= n_traces*doti; doti += 1; print "."; end   # progress bar
			File.write(file, File.read(file).unpack("C*").select.with_index{|c,i|alt[i]}.pack("C*"))
		end
	elsif mode == :txt
		all_files.each_with_index do |file,i|
			if verbose and i*ndots >= n_traces*doti; doti += 1; print "."; end   # progress bar
			File.write(file + ".flt", "")
			File.open(file + ".flt", 'a') do |out|
				File.readlines(file).zip(alt).each do |line_mask|
					out.write(line_mask[0]) if line_mask[1]
				end
			end
		end
	end
	puts if verbose
end