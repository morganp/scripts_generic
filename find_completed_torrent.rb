#!/usr/bin/env ruby 

require './aversa-0.3/aversa'

watchdir1  = "/Users/name/torrents/watch/"
watchdir2  = "/Users/name/torrents/watchx/"
downloaddir  = "/Users/name/04-Downloads/"
completedir  = "/Users/name/05-Complete/"


watchdir   = [watchdir1, watchdir2]
activeFiles    = Array.new
completedFiles = Array.new


i=0

#Search Download Dir for 
(watchdir).each do |watch|
   puts watch
   Dir.foreach(watch) do |x|
      begin
         if x.match(/^[a-zA-Z0-9\[\]]+[-a-zA-Z0-9_.\[\] ]*(torrent)$/)
            meta = MetaInfo.new
            meta.decode(watch + x)
            filename = meta.name
            activeFiles[i] = filename
            i=i+1
         end
      rescue
         puts ""
         puts "ERROR with : " + watch + x
      end
   end
end

puts "Active Files #{i}"

j = 0
k = 0
# Cycle through directory  
Dir.foreach(downloaddir) do |d|  
 k=k+1
 active = false
 activeFiles.each do |activeFile|
   if (activeFile == d) 
      active  = true
   end
 end
 if (active == false) 
    completedFiles[k] = d
    puts " mv \"#{downloaddir + completedFiles[k]}\" #{completedir}"
    j=j+1
 end
end 
puts "Completed Files #{j}"
puts "Files #{k}"


