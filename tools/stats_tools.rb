# introduce some basic statistics tools for Enumerable and Hash

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
	
	def sup
		return -Float::INFINITY if empty?
		return max
	end
	
	def inf
		return Float::INFINITY if empty?
		return min
	end
	
	def print_stats(list, prec = 2)
		puts "      n = #{n}" if list.include? :n
		puts "    sum = %.*f" % [prec, sum] if list.include? :sum
		puts "   mean = %.*f" % [prec, mean] if list.include? :mean
		puts " median = %.1f" % [median] if list.include? :median
		puts "    dev = %.*f" % [prec, dev] if list.include? :dev
		puts "    max = %.*f" % [prec, sup] if list.include? :max
		puts "    min = %.*f" % [prec, inf] if list.include? :min
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
		empty? ? -Float::INFINITY : max_by{|k,v|v}[1]
	end
	
	def print_hist(max_width = 100)
		each{|k,v|self[k] = v.to_f/max_v} if max_v > max_width
		sort.each do |k,v|
			puts "#{k}: " + "\u2588" * v.to_i + " (%.2f)" % [v]
		end
	end
end