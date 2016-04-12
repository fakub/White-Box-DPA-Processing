# generate trace preview in given address and row range
# can split the trace automatically into several images

# approx. half of maximum size
GRAPH_HEIGHT = 0x1000
GRAPH_WIDTH = 0x400

# recursive method for adding a node to plot
def add_node_to_plot(node, plot, addr_offset, row_offset, addr_div, row_div)
	if node.has_key? :data
		node[:data].each do |d|   # d ~ {row: row, addr: addr, length: words[2].hex, val: 1}
			plot.set((d[:row] - row_offset)/row_div, (d[:addr] - addr_offset)/addr_div, d[:length])
		end
	else
		node.each do |key, val|
			add_node_to_plot(val, plot, addr_offset, row_offset, addr_div, row_div)
		end
	end
end

# generate view method itself
# magic ...
def gen_view(filename, addr_from, addr_to, line_from, line_to, split_files, row_div_arg, addr_div_arg, verbose = false)
	puts "\nGenerating preview ..."
	
	begin
		h = {}
		row = -1
		
		puts "\n\tFilling hash tree ..." if verbose   # fill hash tree
		File.open(filename, 'rb').each do |line|
			row += 1
			next if row < line_from
			
			words = line.split(/\W+/)
			addr = words[1].hex
			next if addr < addr_from or addr > addr_to
			
			node = h
			
			(2*GS[:addr_len]-1).downto(0) do |i|
				k = ((addr >> (4*i)) & 0xf)
				node[k] = {} unless node.has_key? k
				node = node[k]
			end
			
			node[:data] = [] if node[:data].nil?
			node[:data] << {row: row, addr: addr, length: words[2].hex, val: 1}
			
			node[:dumb0] = 0; node[:dumb1] = 0; node[:dumb2] = 0; node[:dumb3] = 0; node[:dumb4] = 0; node[:dumb5] = 0; node[:dumb6] = 0; node[:dumb7] = 0; node[:dumb8] = 0; node[:dumb9] = 0; node[:dumba] = 0; node[:dumbb] = 0; node[:dumbc] = 0; node[:dumbd] = 0; node[:dumbe] = 0; node[:dumbf] = 0;
			
			break if row > line_to
		end
		
		row_div = row_div_arg.nil? ? ((row - line_from)/GRAPH_HEIGHT + 1) : row_div_arg.hex
		
		puts "\tSplitting tree ..." if verbose   # find important nodes
		nodes = [h]
		singletons = []
		begin
			# find a node with minimum subnodes
			minimal = nodes.min_by{|node|node.length}
			break if minimal.has_key?(:data) or (nodes.length + minimal.length - 2 > split_files)
			# replace it with these nodes
			nodes.delete_if{|node|node == minimal}
			minimal.each do |key, value|
				nodes << value
			end
			# go deeper if any node has single subnode
			begin
				change = false
				nodes.select{|no|no.length == 1}.each do |single|
					nodes.delete_if{|node|node == single}
					nodes << single.values.first
					change = true
				end
			end while change
			# move singletons
			nodes.select{|no|no.has_key? :data}.each do |singleton|
				nodes.delete_if{|node|node == singleton}
				singletons << singleton
			end
		end while nodes.length < split_files
		
		filenames = []
		puts "\tGenerating plots ..." if verbose   # generate plots
		nodes.each do |node|
			puts "\t----------------\n\tStarting new node" if verbose
			start = node
			stop  = node
			while not start.has_key? :data
				start = start[start.keys.sort.first]
			end
			while not stop.has_key? :data
				stop = stop[stop.keys.sort.last]
			end
			start_addr = start[:data].first[:addr]
			stop_addr = stop[:data].first[:addr]
			
			addr_div = addr_div_arg.nil? ? ((stop_addr - start_addr)/GRAPH_WIDTH + 1) : addr_div_arg.hex
			
			puts "\tAdding points to %0#{2*GS[:addr_len]}x--%0#{2*GS[:addr_len]}x" % [start_addr, stop_addr] if verbose
			p = Plot.new
			
			add_node_to_plot(node, p, start_addr, line_from, addr_div, row_div)
			
			puts "\tTop line: #{line_from}\n\tLines per pixel: #{row_div}\n\tLeftmost address: #{"0x%x" % start_addr}\n\tAddresses per pixel: #{addr_div}" if verbose
			
			puts "\tPlotting         %0#{2*GS[:addr_len]}x--%0#{2*GS[:addr_len]}x" % [start_addr, stop_addr] if verbose
			outfile = "#{filename}__%0#{2*GS[:addr_len]}x--%0#{2*GS[:addr_len]}x__#{row_div}x#{addr_div}.png" % [start_addr, stop_addr]
			p.plot(outfile)
			filenames << outfile
		end
		
		return filenames
		
	rescue Errno::ENOENT
		$stderr.puts "File '" + filename + "' does not exist!"
	end
end