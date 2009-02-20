#!/usr/bin/env ruby 

require 'aversa-0.3/aversa'

watchdir1  = "/Users/name/torrents/watch/"
watchdir2  = "/Users/name/torrents/watchx/"
downloaddir  = "/Users/name/04-Downloads/"
completedir  = "/Users/name/05-Complete/"

#m = MetaInfo.new
#setup = "aversa-0.3/Demons.S01E05.WS.PDTV.XviD-RiVER.torrent"
#m.decode(setup)
#m.print


activeFiles    = Array.new
completedFiles = Array.new


i=0

#Search Download Dir for 
Dir.foreach(watchdir1) do |x| 
   if x.match(/^[a-zA-Z0-9]?[a-zA-Z0-9_.-]*(torrent)$/)
      meta = MetaInfo.new
      meta.decode(watchdir1 + x)
      filename = meta.name
      activeFiles[i] = filename
      i=i+1
   end
end
Dir.foreach(watchdir2) do |x| 
   if x.match(/^[a-zA-Z0-9]?[a-zA-Z0-9_.-]*(torrent)$/)
      meta = MetaInfo.new
      meta.decode(watchdir2 + x)
      filename = meta.name
      activeFiles[i] = filename
      i=i+1
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


