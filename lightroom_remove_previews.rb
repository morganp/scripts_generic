#!/usr/bin/env ruby 

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

class Option
    #
    # Return a structure describing the options.
    #
    def self.parse(args)
      # The options specified on the command line will be collected in *options*.
      # We set default values here.
      options = OpenStruct.new

      options.verbose   = false
      options.report      = false
      options.remove      = false
      options.leftovers = nil
       

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: example.rb [options]"
        opts.separator ""
        opts.separator "Specific options:"

         # Boolean switch.
         opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
           options.verbose = v
         end
        
         opts.on("-r", "--[no-]report", "Report File Sizes") do |v|
            options.report = v
         end
          
         opts.on("-d", "--[no-]remove", "Remove Files") do |v|
            options.remove = v
         end

        opts.separator ""
        opts.separator "Common options:"

        # No argument, shows at tail.  This will print an options summary.
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        # Another typical switch to print the version.
        opts.on_tail("--version", "Show version") do
          #puts OptionParser::Version.join('.')
          puts "Version 0.1.0"
          exit
        end
      end
      
      options.leftovers = opts.parse!(args)
      options
    end  # parse()

  end  # class options

  


###  CONFIGURATION DATA   ###

#Top level Directory containg all Licghtroom catalogs
lightroom = "~/Pictures/Pictures400D/RAW"




#Small function to run a command and output return values
def do_and_report(command)
   f = open("| #{command}")
   g = Array.new
   while (foo = f.gets)
      g << foo
   end
   g.each do |element|
      puts element
   end
end

   options = Option.parse(ARGV)

   if options.report == true
      command = "find #{lightroom} -iname \"*.lrdata\" | xargs -I{} du -sh {}"
      do_and_report(command)
   end
   
   if options.remove == true
      command = "find #{lightroom} -iname \"*.lrdata\" | xargs -I{} rm -r {}"
      puts "Remove"
      do_and_report(command)
   end 

