#!/usr/bin/env ruby 

#Array of Files containing matching text
matchingFiles = []

## Build list of matching files
Dir.foreach("./") do |x| 
   if File.file?(x) 
       begin
          file = File.new(x, "r")
          while (line = file.gets)
             #Check for first command line argument
	     if line =~ /#{ARGV[0]}/
               matchingFiles |= [x]
             end
         end
         file.close
      rescue => err
         puts "Exception: #{err}"
         err
      end
   end
end

## Now go back through All files and dont print the ones in the matching list
Dir.foreach("./") do |x| 
   if File.file?(x) 
      ##File containg string
      #if not matchingFiles.rindex(File.basename(x)).nil? 
      #   puts(" #{matchingFiles.rindex(File.basename(x))}: #{x} ")
      #end
      if not x =~ /^\./
         #Files not containing String
         if matchingFiles.rindex(File.basename(x)).nil?
            puts("#{x}")
            #Format for copy & paste 
            #puts(" rm \"#{x}\" ")
         end   
      end
   end
end

