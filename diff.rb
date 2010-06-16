#!/usr/bin/env ruby

require 'find'

class DiffFolders

   #This is not recursive so not very efficient if a top level folder not found.
   # ie will still check all daughter files even though parent does not exist

   def initialize (d1, d2)
      @d1 = d1
      @d2 = d2
      check_dirs_exist

      build_flat_structure
      # Perfom most efficient diffing
      level1_folder_diff

   end

   def check_dirs_exist
      t1 = File.exists?(@d1)
      t2 = File.exists?(@d2)
      msg = Array.new

      #Which files caused exception 
      msg << @d1 if not t1
      msg << @d2 if not t2
          
      #Format Exception message
      if msg.size == 1
         msg_string = msg[0] + " does not Exist"
      else 
         msg_string = msg[0] + " and " + msg[1] + " do not Exist"
      end

      if not (t1 and t2)
         raise ArgumentError, "#{msg_string}", caller
      end

   end

   def build_flat_structure
      #Store All file nodes 
      @f1_array = get_file_list(@d1)
      @f2_array = get_file_list(@d2)
   end

   def get_file_list(fx)
      fx_array = Array.new
      # Get all files recursively
      Find.find(fx) do |f|

         #TODO the files to skip checks go here
         #Remove start of path from output as this will always be uniqe
         f[fx] = ""
         fx_array << f
      end
      return fx_array
   end


   ####################################################
   ### Diff folders based on file existance
   ####################################################
   def level1_folder_diff

      #Remove Items from array 1 that are in array 2
      #Report missing items
      @f2_array.each do |f|
            @f1_array.delete(f) { puts "#{@d1} missing #{f}" }
      end

      #Report not deleted Items in array
      @f1_array.each do |f|
         puts "#{@d2} missing #{f}"
      end
   end

   ####################################################
   ### Diff folders based on files time stamps
   ####################################################
   def level2_folder_diff(f1_array, f2_array)
      #TODO
   end

   ####################################################
   ### Diff folders based on file sizes
   ####################################################
   def level3_folder_diff(f1_array, f2_array)
      #TODO
   end

   ####################################################
   ### Diff folders based on hash of files
   ####################################################
   def level4_folder_diff(f1_array, f2_array)
      #TODO
   end

end

#Run if calles directly
if $0 == __FILE__

   #TODO proper options need to be added
   # --no-svn
   # --no-git
   # --no-dsstore
   # --no-thumbs.db
   # --no-all (all of the above)

   if not ARGV.size == 2
      puts "Correct usage is :"
      puts " #{__FILE__} directory1 directory2"
      exit 1
   end

   begin
      diff = DiffFolders.new(ARGV[0], ARGV[1])
   rescue
      puts "Caught Exception"
      puts $!
   end
end
