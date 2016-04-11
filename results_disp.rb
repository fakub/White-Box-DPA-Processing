#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ ./#{File.basename(__FILE__)} name attack_name (loc_limit=10.0 type=x0f outmode=txt(/latex) verbose=false)

") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

arg_attn = ARGV[1]
arg_loc_limit = ARGV[2]
arg_type = ARGV[3]
arg_outmode = ARGV[4]
arg_verbose = ARGV[5]

outmode = ["txt", "latex"].include?(arg_outmode) ? arg_outmode : "txt"
emph = outmode == "latex" ? {true => "$\\blacksquare$", false => "$\\boxtimes$"} : {true => "\u2588", false => "\u259e", ltd: {true => "\u2584", false => " "}}
# correct: "\u2592"
verbose = arg_verbose.nil? ? true : arg_verbose == "true"
loc_limit = (arg_loc_limit.to_f <= 0) ? 10.0 : arg_loc_limit.to_f
type = arg_type.nil? ? :x0f : arg_type.to_sym

path = "#{settings.attack_dir}/#{arg_attn}"
line_len = 153

# load processed results
proc_res = YAML.load(File.read("#{path}_results.yaml"))

cand_gaps = []
leak_bit = [0] * 8
target_group_leaks = {}

if outmode == "latex"
	puts "\\hline"
	#~ puts "\\multirow{2}{*}{Byte} & \\multicolumn{24}{c|}{Target bits} \\\\"
	puts "Target & \\multicolumn{24}{c|}{Target bits} \\\\"
	#~ puts "\\cline{2-25}"
	#~ puts "~ & \\multicolumn{3}{c|}{0. bit} & \\multicolumn{3}{c|}{1. bit} & \\multicolumn{3}{c|}{2. bit} & \\multicolumn{3}{c|}{3. bit} & \\multicolumn{3}{c|}{4. bit} & \\multicolumn{3}{c|}{5. bit} & \\multicolumn{3}{c|}{6. bit} & \\multicolumn{3}{c|}{7. bit} \\\\"
	puts "\\hline"
end

proc_res[:bytes].each.with_index do |byte_res, byte|
	next if byte_res.nil?
	ctr = 0
	if outmode == "txt" and verbose
		puts "\n   Results of #{byte}. byte"
		puts "–" * line_len
	end
	
	long = byte_res[:targets].size > 16
	byte_res[:targets].sort.each do |target_str, target_res|
		next if target_res.nil?
		ctr += 1
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
		
		if gap > loc_limit
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
		
		if verbose
			if outmode == "txt"
				# readable output
				em = correct ? \
						(gap > loc_limit ? emph[true] : emph[:ltd][true]) : \
						(gap > loc_limit ? emph[false] : emph[:ltd][false])
				if long
					print "#{em}%2.0f" % [gap]
					puts if ctr % 51 == 0
				else
					print " | #{em} %4.1f (%3d)" % [gap, true_cand_pos]
					puts if ctr % 51 == 0
				end
			elsif byte == 0   #!#
				# LaTeX output
				#~ print "#{byte}.&"
				#~ print "{\\tt #{target_str}}&"
				# format: ... | gap true_cand_pos | ...
				#~ print (0..7).to_a.map{|tb|("%.1f&" % [line[tb][0]]).sub(".", "&") + (line[tb][3] ? emph[true] : line[tb][4].to_s)}.join("&")
				#~ puts "\\\\"
				#~ puts "\\hline"
			end
		end
	end
	puts "\n"
end

if outmode == "txt"
	puts "\n   Overal results"
	puts "=" * line_len
	
	puts " #{emph[true]} correct candidates' values byte-wise (out of 255):"
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
	
	puts " #{emph[true]} correct candidates' values overal (out of 4080):"
	true_cand_gaps.print_stats([:n, :mean, :median, :dev, :max])
	puts "---------------------------------"
	
	puts " #{emph[false]} incorrect candidates' values overal (out of 4080):"
	false_cand_gaps.print_stats([:n, :mean, :median, :dev, :max])
	puts "---------------------------------"
	
	puts " 2nd best:"
	second_n.print_stats([:mean, :dev, :max])
	puts "---------------------------------"
	
	#~ puts " #{emph[false]} false positives value:"
	#~ all_false_max.print_stats(true, false)
	#~ puts "---------------------------------"
	
	puts " # of leaks for each bit:"
	puts leak_bit.to_s
	leak_bit.print_hist
	puts "---------------------------------"
	
	puts " # of leaks for each group of targets (type = ...):"
	gl_n = Hash[target_group_leaks.map{|k,v|[k,v[:gaps].size.to_f / (v[:size] * 16) * 100]}]
	puts gl_n.to_s
	gl_n.print_hist
end
