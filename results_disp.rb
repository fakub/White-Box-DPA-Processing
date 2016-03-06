#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
	$ #{File.basename(__FILE__)} name (n_traces=-1 loc_limit=9.0 glob_limit=27.0 outmode=txt/latex verbose=false)") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

arg_ntr = ARGV[1]
arg_loc_limit = ARGV[2]
arg_glob_limit = ARGV[3]
arg_outmode = ARGV[4]
arg_verbose = ARGV[5]

n_traces = (arg_ntr.to_i <= 0) ? settings[:n_traces] : arg_ntr.to_i
outmode = ["txt", "latex"].include?(arg_outmode) ? arg_outmode : "txt"
emph = outmode == "latex" ? {true => "$\\blacksquare$", false => "$\\boxtimes$"} : {true => "\u2588", false => "\u259e", ltd: {true => "\u2584", false => "\u2596"}, correct: "\u2592"}
verbose = arg_verbose.nil? ? true : arg_verbose == "true"
loc_limit = (arg_loc_limit.to_f <= 0) ? 9.0 : arg_loc_limit.to_f
glob_limit = (arg_glob_limit.to_f <= 0) ? 27.0 : arg_glob_limit.to_f

path = "#{settings.attack_dir}/#{n_traces}"
line_len = 114

# load processed results
proc_res = YAML.load(File.read("#{path}_results.yaml"))
all_true_max = []
all_true_max_n = []
all_false_max = []
all_false_max_n = []
all_leak_bit = [0] * 8
target_success = {}

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
	if outmode == "txt"
		puts "\n   Results of #{byte}. byte"
		puts "=" * line_len if verbose
		puts " Target  |                                  Target bits" + " " * (line_len - 56) + "|" if verbose
	end
	
	true_max = []
	false_max = []
	false_cands = {}
	leak_bit = [0] * 8
	
	byte_res[:targets].sort.each do |target, target_res|
		next if target_res.nil?
		target_str = "%02x" % [target]
		
		line = target_res[:line]
		cand_vals = target_res[:cand_vals]
		true_cand = target_res[:true_cand]
		
		# keep only values > loc_limit
		cand_vals.each{|cand,vals|vals.select!{|v|v > loc_limit}}
		cand_sums = cand_vals.map{|cand,vals|[cand,vals.sum]}.to_h
		
		best_cand, max_val = cand_sums.max_by{|cand,sum|sum}
		success = best_cand == true_cand
		
		if max_val > glob_limit
			if success
				#~ target_success[target_str] = [0.0, 0] unless target_success.has_key? target_str
				#~ target_success[target_str][0] += cand_sum[best_cand]
				#~ target_success[target_str][1] += line.count{|e|e[1] == best_cand}
				target_success[target_str] = 0 unless target_success.has_key? target_str
				target_success[target_str] += line.count{|e|e[3] and e[0] > loc_limit}
				
				true_max << cand_vals[best_cand]
				line.select{|e|e[3] and e[0] > loc_limit}.each{|e|leak_bit[e[2] % 8] += 1}
			else
				false_max << cand_vals[best_cand]
				false_cands[best_cand] = [] unless false_cands.has_key? best_cand
				false_cands[best_cand] << cand_vals[best_cand].sum
			end
		end
		
		if verbose
			if outmode == "txt"
				# readable output
				puts "-" * line_len
				print "   0x#{target_str}  |"
				8.times do |tb|
					em = (line[tb][1] == best_cand) ? \
							(cand_sums[best_cand] > glob_limit ? emph[line[tb][3]] : emph[:ltd][line[tb][3]]) : \
							(line[tb][1] == true_cand ? emph[:correct] : " ")
					print "%3d #{em}%5.2f%s|" % [line[tb][4], line[tb][0], line[tb][1] == true_cand ? "/#{line[tb][2] % 8}" : "  "]
				end
				puts
			elsif byte == 0   #!#
				# LaTeX output
				#~ print "#{byte}.&"
				print "{\\tt #{target_str}}&"
				# format: ... | gap true_cand_pos | ...
				print (0..7).to_a.map{|tb|("%.1f&" % [line[tb][0]]).sub(".", "&") + (line[tb][3] ? emph[true] : line[tb][4].to_s)}.join("&")
				puts "\\\\"
				puts "\\hline"
			end
		end
	end
	puts "=" * line_len if outmode == "txt"
	
	all_true_max << true_max
	all_true_max_n << true_max.size
	all_false_max << false_max
	all_false_max_n << false_max.size
	all_leak_bit = all_leak_bit.zip(leak_bit).map{|e|e.sum}
	
	if outmode == "txt"
		# readable output
		
		puts " #{emph[true]} correct candidates:"
		true_max.flatten!
		true_max.print_stats(true, false)
		puts "---------------------------------"
		puts " #{emph[false]} false positives:"
		false_max.flatten!
		false_max.print_stats(true, false)
		puts "---------------------------------"
		false_cands.sort{|a,b|a[1].length <=> b[1].length}.each do |cand,vals|
			puts "    %02x" % [cand]
			vals.print_hist
			#~ vals.print_stats(true, true, false, false, false)
		end
		puts "---------------------------------"
		puts " # of leaks for each bit:"
		leak_bit.print_hist
	end
end

all_true_max.flatten!
all_false_max.flatten!

if outmode == "txt"
	puts "\n Overal results"
	puts "=" * line_len
	
	puts " # of correct candidates:"
	all_true_max_n.print_stats(false, false)
	puts " # of false candidates:"
	all_false_max_n.print_stats(false, false)
	puts "---------------------------------"
	
	puts " #{emph[true]} correct candidates value:"
	all_true_max.print_stats(true, false)
	puts "---------------------------------"
	puts " #{emph[false]} false positives value:"
	all_false_max.print_stats(true, false)
	puts "---------------------------------"
	puts " # of leaks for each bit:"
	all_leak_bit.print_hist
	puts "---------------------------------"
	puts " # of leaks for each target:"
	target_success.print_hist
end
