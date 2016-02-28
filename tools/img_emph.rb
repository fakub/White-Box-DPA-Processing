require 'rmagick'
include Magick

def emph_in_image(x, y, val, filename)
	im = ImageList.new(filename)
	
	(x-4).upto(x+4){|i|im.pixel_color(i,y-4,"hsl(#{val},255,100)"); im.pixel_color(i,y+4,"hsl(#{val},255,100)")}
	(x-3).upto(x+3){|i|im.pixel_color(i,y-3,"hsl(#{val},255,100)"); im.pixel_color(i,y+3,"hsl(#{val},255,100)")}
	(y-4).upto(y+4){|j|im.pixel_color(x-4,j,"hsl(#{val},255,100)"); im.pixel_color(x+4,j,"hsl(#{val},255,100)")}
	(y-3).upto(y+3){|j|im.pixel_color(x-3,j,"hsl(#{val},255,100)"); im.pixel_color(x+3,j,"hsl(#{val},255,100)")}
	
	im.write("png:" + filename)
end