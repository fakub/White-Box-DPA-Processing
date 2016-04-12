# load & save mask from & to file

def mask_from_file(file)
	File.read(file).scan(/./).map{|c|c == "1"}
end

def mask_to_file(mask, file)
	File.write(file, mask.map{|b|b ? "1" : "0"}.join)
end

