module Enumerable
	def sum
		inject(0){|s,e|s+e}
	end
	
	def n
		size
	end
	
	def mean
		sum.to_f / n
	end
	
	def median
		return Float::NAN if empty?
		sorted = sort
		(sorted[(length - 1) / 2] + sorted[length / 2]).to_f / 2
	end
	
	def var
		m = mean
		inject(0){|ssq, e| ssq + (e-m)**2 }.to_f / (n-1)
	end
	
	def dev
		Math.sqrt var
	end
	
	def print_stats(pn = true, ps = true, pm = true, pmed = true, pd = true, prec = 2)
		puts "      n = #{n}" if pn
		puts "    sum = %.*f" % [prec, sum] if ps
		puts "   mean = %.*f" % [prec, mean] if pm
		puts " median = %.1f" % [median] if pmed
		puts "    dev = %.*f" % [prec, dev] if pd
	end
	
	def print_hist(max_width = 100)
		a = self
		a = map{|e|e.to_f/max} if max > max_width
		each.with_index do |v,i|
			puts "#{i}: " + "\u2588" * v.to_i + " (%.2f)" % [v]
		end
	end
end

class Hash
	def max_v
		max_by{|k,v|v}[1]
	end
	
	def print_hist(max_width = 100)
		each{|k,v|self[k] = v.to_f/max_v} if max_v > max_width
		sort.each do |k,v|
			puts "#{k}: " + "\u2588" * v.to_i + " (%.2f)" % [v]
		end
	end
end