def addr_begin(pngfile)
	pngfile.match(/__[0-9a-fA-F]{12}\-\-[0-9a-fA-F]{12}__[0-9]+?x[0-9]+?\.png/).to_s.split("--")[0][2..-1].hex
end

def addr_div(pngfile)
	pngfile.match(/__[0-9]+?x[0-9]+?\.png/).to_s.split("x")[1].split(".")[0].to_i
end

def row_div(pngfile)
	pngfile.match(/__[0-9]+?x[0-9]+?\.png/).to_s.split("x")[0][2..-1].to_i
end

def range_mask(fltfile, addr_from, addr_to, row_from, row_to)
	File.read(fltfile).split("\n").map.with_index do |line,row|
		addr = line.split[1].hex
		addr >= addr_from and addr <= addr_to and row >= row_from and row <= row_to
	end
end

def range_filtering(settings, playground = true)
	mypath = playground ? settings.man_view_dir : settings.arf_dir
	
	fltfile = settings.txt_trace
	$stderr.puts("Fatal: text trace not found in \"#{settings.traces_dir}\")") or exit unless File.exists? fltfile
	
	addr_beg = settings[:addr_beg]
	addr_div = settings[:addr_div]
	row_div = settings[:row_div]
	
	FileUtils.rm_rf(mypath, secure: true)
	FileUtils.mkpath(mypath)
	FileUtils.cp(fltfile, mypath)
	fltfile = "#{mypath}/#{File.basename fltfile}"
	
	apixel_from = nil; apixel_to = nil; rpixel_from = nil; rpixel_to = nil
	addr_from = nil;   addr_to = nil;   row_from = nil;    row_to = nil
	i = 0; last_png = nil
	
	begin
		i += 1
		puts "Provide desired address/row range in pixels from left/top."
		
		begin
			print "Address pixel from: "
			apixel_from = $stdin.gets.to_i.abs
			print "Address pixel to:   "
			apixel_to = $stdin.gets.to_i
			apixel_to = (apixel_to <= 0) ? Float::INFINITY : apixel_to
		end until apixel_from < apixel_to or $stderr.puts("Address from must be smaller than Address to. You can use 0 instead of 0xffffffffffff.")
		begin
			print "Row pixel from: "
			rpixel_from = $stdin.gets.to_i.abs
			print "Row pixel to:   "
			rpixel_to = $stdin.gets.to_i
			rpixel_to = (rpixel_to <= 0) ? Float::INFINITY : rpixel_to
		end until rpixel_from < rpixel_to or $stderr.puts("Row from must be smaller than Row to. You can use 0 as infinity.")
		
		addr_from = addr_beg + apixel_from * addr_div
		addr_to = addr_beg + apixel_to * addr_div
		row_from = rpixel_from * row_div
		row_to = rpixel_to * row_div
		
		split_files = 1
		row_div_arg = nil
		addr_div_arg = nil
		if playground
			print "Split files: "
			split_files = $stdin.gets.to_i
			split_files = (split_files <= 0) ? 1 : split_files
			print "Row div (dangerous): "
			row_div_arg = $stdin.gets.to_i.abs
			row_div_arg = row_div_arg == 0 ? nil : row_div_arg
			print "Address div (dangerous): "
			addr_div_arg = $stdin.gets.to_i.abs
			addr_div_arg = addr_div_arg == 0 ? nil : addr_div_arg
		end
		
		pvfiles = gen_view(fltfile, addr_from, addr_to, row_from, row_to, split_files, addr_div_arg, row_div_arg)
		pvfiles.each.with_index do |pvfile,j|
			FileUtils.mv pvfile, "#{mypath}/%02d_%02d__#{File.basename pvfile}" % [i,j]
			last_png = "#{mypath}/%02d_%02d__#{File.basename pvfile}" % [i,j]
		end
		
		puts "\nCheck new files in \"#{mypath}\"."
		print playground ? "Finished? (Y/n) " : "Start filtering with this range? (Y/n) "
	end until $stdin.gets.chomp == "Y"
	
	settings[:apixel_from] = apixel_from
	settings[:apixel_to] = apixel_to
	settings[:rpixel_from] = rpixel_from
	settings[:rpixel_to] = rpixel_to
	if playground
		settings[:split_files] = split_files
		settings[:row_div_arg] = row_div_arg
		settings[:addr_div_arg] = addr_div_arg
	end
	
	FileUtils.rm_rf(settings.flt_traces_dir, secure: true)
	FileUtils.mkpath(settings.bin_flt_traces_dir)
	
	mask_to_file(range_mask(fltfile, addr_from, addr_to, row_from, row_to), settings.range_filter_file) unless playground
	
	return last_png
end