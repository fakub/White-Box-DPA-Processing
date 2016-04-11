def handle_existing_name(settings)
	FileUtils.rm_rf(settings.path, secure: true) if Dir.exists?(settings.path) and not File.exists?(settings.const_filter_file)
	
	if Dir.exists?(settings.path)
		print "
Name \"#{settings[:name]}\" already exists.

Merge new traces with existing (M), or
delete old traces and acquire new (D), or
use different name (N), or
cancel (C)? "
		ch = $stdin.gets.chomp
		if merge = ch == "M"
			puts "\nWill try to merge."
		elsif ch == "D"
			FileUtils.rm_rf(settings.path, secure: true)
			puts "\nOld traces deleted."
		elsif ch == "N"
			print "\nEnter new name: "
			begin
				newname = $stdin.gets.chomp
			end while Dir.exists?("#{GS[:data_dir]}/#{newname}") and (print("Name #{newname} exists, enter a different name: ") or true)
			settings[:name] = newname
			puts "Continuing with a new name \"#{newname}\"."
		else
			$stderr.puts "\nCancelled, exiting." or exit
		end
	end
	
	return merge
end