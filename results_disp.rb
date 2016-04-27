#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ ./#{File.basename(__FILE__)} <name> <attack_name> [#{"%4.1f" % [GS[:strong_cand_bound]]} xf0 txt false]

where
	 #{"%4.1f" % [GS[:strong_cand_bound]]} ... limit for strong candidate
	  xf0 ... group targets in statistics by:
	                nothing ... nil
	               lin. map ... p
	             1st 4 bits ... xf0
	            last 4 bits ... x0f
	  txt ... output mode (txt/latex)

") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

# tell hint
puts "
See more options by running
	$ ./#{File.basename(__FILE__)}" if ARGV[2].nil?

# read arguments
arg_attn = ARGV[1]
arg_strong_limit = ARGV[2]
arg_type = ARGV[3]
arg_outmode = ARGV[4]
# set limit for strong candidate
strong_limit = (arg_strong_limit.to_f <= 0) ? GS[:strong_cand_bound] : arg_strong_limit.to_f
# set target grouping type
type = arg_type.nil? ? :xf0 : arg_type.to_sym
# set output mode & emphasizing symbols
outmode = ["txt", "latex"].include?(arg_outmode) ? arg_outmode : "txt"
emph = outmode == "latex" ? \
         {true => "{$\\blacksquare$}", false => "", ltd: {true => "{\\weak$\\blacksquare$}", false => ""}} : \
         {true => "\u2588", false => "\u259e", ltd: {true => "\u2584", false => " "}}   # correct: "\u2592"

# set path and terminal width
path = "#{settings.attack_dir}/#{arg_attn}"
line_len = GS[:terminal_width]

# load processed results
proc_res = YAML.load(File.read("#{path}_results.yaml"))

# init
cand_gaps = []
leak_bit = [0] * 8
target_group_leaks = {}

# print header
if outmode == "txt"
	# text output
	puts "
 Formats of results
--------------------
 More than #{GS[:long_results]} results per byte:
		#{emph[true]}17
	where
		#{emph[true]}  ... strong correct candidate, can be further
			#{emph[false]} ... strong incorrect,
			#{emph[:ltd][true]} ... weak correct,
			#{emph[:ltd][false]} ... weak incorrect,
		17 ... 17% gap.
 Less than #{GS[:long_results]} results per byte:
		| #{emph[false]} 13.4 (251)
	where
		#{emph[false]}     ... see before,
		13.4  ... 13.4% gap,
		(251) ... rank of correct candidate.
--------------------"
else
	# LaTeX output
	res_per_line = proc_res[:bytes].first[:targets].size
	puts "\\begin{tabular}{| c | #{"r@{.} l@{\\quad}r | " * res_per_line}}"
	puts "	\\hline"
	puts "	Byte & \\multicolumn{#{res_per_line * 3}}{c|}{Targets (percentual gap\\quad rank)} \\\\"
	puts "	\\hline"
	puts "	\\hline"
end

proc_res[:bytes].each.with_index do |byte_res, byte|
	next if byte_res.nil?
	ctr = 0
	if outmode == "txt"
		# text output
		puts "\n #{byte}. byte"
		puts "–" * line_len
	else
		# LaTeX output
		print "	#{byte}"
	end
	
	long = byte_res[:targets].size > GS[:long_results]
	byte_res[:targets].sort.each do |target_str, target_res|
		next if target_res.nil?
		ctr += 1
		# sample results:
		#~ :gap: 2.401379322910968
		#~ :cand: 107
		#~ :leak_index: 840
		#~ :true_cand_pos: 213
		#~ :correct: false
		
		gap = target_res[:gap]
		cand = target_res[:cand]
		leak_index = target_res[:leak_index]
		true_cand_pos = target_res[:true_cand_pos]
		correct = target_res[:correct]
		
		# for statistics purposes
		if gap > strong_limit
			cand_gaps[byte] = {} if cand_gaps[byte].nil?
			cand_gaps[byte][cand] = [] unless cand_gaps[byte].has_key? cand
			cand_gaps[byte][cand] << gap
			if correct
				leak_bit[leak_index % 8] += 1
				# target group and its size
				tg, ts = group_of_target(target_str, type)
				target_group_leaks[tg] = {gaps: [], size: ts} unless target_group_leaks.has_key? tg
				target_group_leaks[tg][:gaps] << gap
			end
		end
		
		em = correct ? \
		     (gap > strong_limit ? emph[true] : emph[:ltd][true]) : \
		     (gap > strong_limit ? emph[false] : emph[:ltd][false])
		if outmode == "txt"
			# text output
			if long
				print "#{em}%2.0f" % [gap]
				puts if ctr % 51 == 0
			else
				print " | #{em} %4.1f (%3d)" % [gap, true_cand_pos]
				puts if ctr % 51 == 0
			end
		else
			# LaTeX output
			print "&#{("%4.1f" % [gap]).gsub(".","&")}&#{true_cand_pos == 0 ? em : true_cand_pos}"
		end
	end
	if outmode == "txt"
		# text output
		puts "\n"
	else
		# LaTeX output
		puts "\\\\
	\\hline"
	end
end

if outmode == "txt"
	# text output
	puts "

 Overall statistics"
	puts "=" * line_len
	
	puts " #{emph[true]} byte-wise values:"
	true_cand_gaps = []
	false_cand_gaps = []
	second_n = []
	
	cand_gaps.each.with_index do |cgs,byte|
		true_cand = proc_res[:bytes][byte][:true_cand]
		
		puts "----------------------\n #{byte}. byte:"
		if cgs.nil? or cgs[true_cand].nil?
			puts "No candidate exceeded the limit."
			next
		end
		cgs[true_cand].print_stats([:n, :sum, :mean])
		
		cgs_sort_n = cgs.sort_by{|cand,gaps|gaps.n}.reverse
		cgs_sort_mean = cgs.sort_by{|cand,gaps|gaps.mean}.reverse
		cgs_sort_sum = cgs.sort_by{|cand,gaps|gaps.sum}.reverse
		
		if cgs.size > 1
			if cgs_sort_n[0][0] == true_cand
				puts " 2nd best by n: 0x%02x" % [cgs_sort_n[1][0]]
				cgs_sort_n[1][1].print_stats([:n])
				second_n << cgs_sort_n[1][1].n
			else
				puts " #{emph[false]} best by n: 0x%02x" % [cgs_sort_n[0][0]]
				cgs_sort_n[0][1].print_stats([:n])
				#~ false_pos << byte
			end
			if cgs_sort_mean[0][0] == true_cand
				puts " 2nd best by mean: 0x%02x" % [cgs_sort_mean[1][0]]
				cgs_sort_mean[1][1].print_stats([:mean])
			else
				puts " #{emph[false]} best by mean: 0x%02x" % [cgs_sort_mean[0][0]]
				cgs_sort_mean[0][1].print_stats([:mean])
				#~ false_pos << byte
			end
			if cgs_sort_sum[0][0] == true_cand
				puts " 2nd best by sum: 0x%02x" % [cgs_sort_sum[1][0]]
				cgs_sort_sum[1][1].print_stats([:sum])
			else
				puts " #{emph[false]} best by sum: 0x%02x" % [cgs_sort_n[0][0]]
				cgs_sort_sum[0][1].print_stats([:sum])
				#~ false_pos << byte
			end
		else
			if cgs.to_a[0][0] == true_cand
				puts "Only correct candidate exceeded the limit."
			else
				puts "Only #{emph[false]} incorrect candidate #{cgs.to_a[0][0]} exceeded the limit."
			end
		end
		
		
		true_cand_gaps.concat cgs[true_cand]
		cgs.each do |cand, gaps|
			false_cand_gaps.concat gaps unless cand == true_cand
		end
	end
	puts "---------------------------------"
	
	#~ puts " False positives: #{false_pos.to_s}"
	#~ puts "---------------------------------"
	
	puts " #{emph[true]} overall values:"
	true_cand_gaps.print_stats([:n, :mean, :median, :dev, :max])
	puts "---------------------------------"
	
	puts " #{emph[false]} overall values:"
	false_cand_gaps.print_stats([:n, :mean, :median, :dev, :max])
	puts "---------------------------------"
	
	puts " 2nd best:"
	second_n.print_stats([:mean, :dev, :max])
	puts "---------------------------------"
	
	#~ puts " #{emph[false]} false positives value:"
	#~ all_false_max.print_stats(true, false)
	#~ puts "---------------------------------"
	
	puts " # of leaks per leaking bit:"
	puts leak_bit.to_s
	leak_bit.print_hist
	puts "---------------------------------"
	
	puts " # of leaks per group of targets (type = #{type}):"
	gl_n = Hash[target_group_leaks.map{|k,v|[k,v[:gaps].size.to_f / (v[:size] * 16) * 100]}]
	puts gl_n.to_s
	gl_n.print_hist
else
	# LaTeX output
	puts "\\end{tabular}"
end

# next steps
tell_the_end
puts
