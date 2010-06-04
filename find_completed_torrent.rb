#!/usr/bin/env ruby 

require 'FileUtils'

path = File.expand_path $0
path = File.dirname(path)

# TODO add check for aversa
require "#{path}/bencoding"
require "#{path}/../aversa-0.3/aversa"

#git clone http://github.com/dydx/RubyTorrent.git
# TODO add check for rubytorrent
require "#{path}/../RubyTorrent/rubytorrent"


def check_envs (envs_to_check)
   failure = false
   envs_to_check.each do |env_to_check|
      if ENV[env_to_check].nil? 
         puts "Add this to ~/.bashrc or Windows variables"
         puts "export " + env_to_check + "='[\"/path/one/\", \"/parh/two/\"]'"
         puts ""
         failure = true
      else
         puts "Using OS User Variable : "  + env_to_check
      end
   end

   if failure 
      puts "Checking for torrents in : ENV['TORRENT_FILES']" 
      puts "Downloaded content from ENV['TEMP_FILES'] which does not have an active torrent"
      puts "   will be moved to ENV['MEDIA_FILES']" 
      puts 
      exit 1
   end
end

check_envs(['MEDIA_FILES', 'TEMP_FILES', 'TORRENT_FILES'])

# use eval to turn string into array of strings (because of the format of saved string)
downloaddir  = eval(ENV['TEMP_FILES'])[0]
completedir  = eval(ENV['MEDIA_FILES'])[0]

puts "Checking for torrents in :" 
pp ENV['TORRENT_FILES']
puts "Downloaded content from #{downloaddir} which does not have an active torrent"
puts "   will be moved to #{completedir}" 
puts 

activeFiles    = Array.new
completedFiles = Array.new


i=0
totalStartTime = Time.now

#Search Download Dir for 
eval(ENV['TORRENT_FILES']).each do |watch|
   puts "Loading Torrents in: " + watch
   Dir.foreach(watch) do |x|
      begin
         if x.match(/^[a-zA-Z0-9\[\]]+[-a-zA-Z0-9_.\[\] ]*(torrent)$/)
            startTime = Time.now
            puts watch + x

            ## TODO Try these parsers in order and fall back appropriately 
            #  Output message to let user know there is a faster parser available

            # gem install rubytorrent
            #There seems to be no good way to get a working copy of ruby torrent
            # will have to release it as a new rubygem
            activeFiles[i] = RubyTorrent::MetaInfo.from_location(watch + x).info.name

            # Aversa 6 times faster than Bencoding
            #meta = MetaInfo.new
            #meta.decode(watch + x)
            #activeFiles[i] = meta.name
            
            #Trying new Torrent Parser
            # Ugh This seems to be very slow and uses massive CPU
            #metainfo = Bencoding.new(watch + x).metainfo
            #activeFiles[i] = metainfo['info']['name']

            execTime = Time.now - startTime
            puts "Execution time #{execTime} seconds."
            

            i=i+1
         end
      rescue
         puts ""
         puts "ERROR with : " + watch + x
      end
   end
end

totalExecTime = Time.now - totalStartTime
puts "Total Execution time #{totalExecTime} seconds."
puts "Active Files #{i}"

j = 0
k = 0
## Cycle through directory  
Dir.foreach(downloaddir) do |d|  
   if d.match(/[^'torrents','.','.DS_Store']/)

      k=k+1
      active = false
      activeFiles.each do |activeFile|
         if (activeFile == d) 
            active  = true
         end
      end
      if (active == false) 
         completedFiles[k] = d
         puts "mv \"#{downloaddir + completedFiles[k]}\" #{completedir}"
         FileUtils::mv("#{downloaddir + completedFiles[k]}", completedir.to_s)
         j=j+1
      end
   end
end 
puts "Completed Files #{j}"
puts "Files #{k}"


