# filter given list of filenames of traces with given mask
# mode can be either :bin (entry per byte), or :txt (entry per line)

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
            if verbose and i*ndots >= n_traces*doti; doti += 1; print "."; end  # progress bar
            # filtering – select those where alt (~ mask) is true
            tr = File.read(file).unpack("C*")
            tr = alt.size.times.collect{|i| tr[i] || 0}                         # some traces might be shorter
            File.write(file, tr.select.with_index{|c,i|alt[i]}.pack("C*"))
        end
    elsif mode == :txt
        all_files.each_with_index do |file,i|
            if verbose and i*ndots >= n_traces*doti; doti += 1; print "."; end  # progress bar
            # init empty output
            File.write(file + ".flt", "")
            # append line of original trace if alt (~ mask) is true
            File.open(file + ".flt", 'a') do |out|
                File.readlines(file).zip(alt).each do |line_mask|
                    out.write(line_mask[0]) if line_mask[1]
                end
            end
        end
    end
    puts if verbose
end
