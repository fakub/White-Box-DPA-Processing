require 'rmagick'
include Magick

class Plot
	def initialize
		@lines = [[0]]
	end
	
	def set(x, y, val)
		@lines[x] = [] if @lines[x].nil?
		@lines[x][y] = val.to_i
	end
	
	def width
		@lines.max_by{|line|line.nil? ? 0 : line.length}.length
	end
	
	def height
		@lines.length
	end
	
	def max
		@lines.max_by{|line|line.nil? ? 0 : line.map(&:to_i).max}.map(&:to_i).max
	end
	
	def plot(filename, margin = 0, verbose = false)
		
		print "\t\tWidth ... " if verbose
		w = width
		puts w if verbose
		
		print "\t\tHeight ... " if verbose
		h = height
		puts h if verbose
		
		m = max
		
		img = Image.new(w + 2*margin,h + 2*margin) { self.background_color = "gray" }
		gc = Draw.new
		gc.stroke = 'white'
		gc.fill = 'white'
		gc.rectangle margin, margin, w+margin-1, h+margin-1
		gc.draw img
		
		@lines.each_with_index do |line,ri|
			unless line.nil?
				line.each_with_index do |e,ci|
					#~ img.pixel_color(ci+margin,ri+margin,"hsl(#{e.to_f/m*360},100,100)") unless e.nil?
					img.pixel_color(ci+margin,ri+margin,"hsl(#{e.to_f/m*360},100,0)") unless e.nil?
				end
			end
		end
		
		puts "\t\tWriting result ... " + filename + ".png" if verbose
		img.write("png:" + filename + ".png")
		
	end
	
	#~ def dump_dat(filename)
		#~ File.open("./plots/files/" + filename + ".dat", 'w') do |f|
			#~ w = width
			#~ @lines.each do |l|
				#~ if l.nil?
					#~ f.write("  0\t" * w + "\n")
				#~ else
					#~ l.each do |e|
						#~ f.write(e.nil? ? "  0\t" : ("%3d\t" % e))
					#~ end
					#~ f.write("  0\t" * (w - l.length) + "\n")
				#~ end
			#~ end
		#~ end
	#~ end
	#~ 
	#~ def gen_gnp(filename, margin = 1)
		#~ File.open("./plots/files/" + filename + ".gnp", "w") do |f|
			#~ f.write(
#~ "reset
#~ 
#~ set lmargin 0
#~ set rmargin 0
#~ set tmargin 0
#~ set bmargin 0
#~ unset key
#~ unset tics
#~ unset colorbox
#~ unset border
#~ 
#~ set term png nocrop size " + (width + 2 * margin).to_s + "," + (height + 2 * margin).to_s + "
#~ set xrange [-" + (margin+1).to_s + ":" + (width  + margin - 1).to_s + "]
#~ set yrange [-" + (margin+1).to_s + ":" + (height + margin - 1).to_s + "] reverse
#~ set cbrange [0:" + max.to_s + "]
#~ 
#~ set out './plots/" + filename + ".png'
#~ plot './plots/files/" + filename + ".dat' matrix with image
#~ 
#~ set term wxt"
			#~ )
		#~ end
	#~ end
end