#!/usr/bin/env ruby

require 'pp'
require 'fileutils'
#puts "Script to move Avi files out of folders"

def check_envs (envs_to_check)
   failure = false
   envs_to_check.each do |env_to_check|
      if ENV[env_to_check].nil? 
         puts "Add this to ~/.bashrc or Windows variables"
         puts "export " + env_to_check + "='[\"/path/one/\"]'"
         puts ""
         failure = true
      else
         puts "Using OS User Variable : "  + env_to_check
      end
   end

   if failure 
      puts "Checking for solitary (single) Media files folders in : ENV['MEDIA_FILES']" 
      puts 
      exit 1
   end
end

check_envs(['MEDIA_FILES'])

#ENV['MEDIA_FOLDER']
@directory_to_sort =  eval(ENV['MEDIA_FILES'])[0]

#get all directories
files = Dir.glob(@directory_to_sort + '*/')

limiter = 10
count   = 0

$date_format = "%I:%M%p %b %d %Y"

log_file = File.new(@directory_to_sort + "move_solitary_media_files.log", "a")
mode = ARGV[0]
mode ||= ""
log_file.puts Time.now.strftime($date_format) + ' : ' + mode

@debug = false
if ARGV[0] == "debug"
 @debug = true
end

media_files_regexp = '(\.avi$|\.mpg$|\.wmv$)'

files.each do |x|
   #if x.match('.*18[\. ]to[\. ]Life.*')
   if count < limiter
      #Count avi files
      avi_count = 0
      last_avi_file = ''

      #puts 'x :' + x
      ##Glob expects regular expression
      # Jail break regular expression syntax as we know it is all part of filename
      x_standard = x.clone
      x.gsub!('[', '\[')
      x.gsub!(']', '\]')
      #puts x
      sub_files = Dir.glob( x + '*')
      sub_files.each do |y|
      #   puts 'y :' + y
         if y.match('sample.*' + media_files_regexp)
            #puts 'Found and Ignoring Sample ' + y
         elsif y.match( media_files_regexp )
            avi_count += 1
            last_avi_file = y
            #puts 'Found avi ' + y
         end
      end

      if avi_count == 1
         puts last_avi_file
         log_file.puts last_avi_file


         if @debug == true
            puts "DEBUG MODE NOT file altering"
         else
            #move last_avi_file to main directory
            FileUtils.mv(last_avi_file, @directory_to_sort )
         
            #Remove the folder conatining file
            # Deos not seem to like the regular expression escaped version
            FileUtils.rm_rf(x_standard)
         end
         #Increase count to limit files being moved
         # Very useful when developing script
         count += 1
      end

      
  # end 
   end

end

log_file.close

