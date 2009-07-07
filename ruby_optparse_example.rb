#!/usr/bin/env ruby 

  require 'optparse'
  require 'optparse/time'
  require 'ostruct'
  require 'pp'

  class OptparseExample


    #
    # Return a structure describing the options.
    #
    def self.parse(args)
      # The options specified on the command line will be collected in *options*.
      # We set default values here.
      options = OpenStruct.new

      options.verbose   = false
      options.time      = 0
      options.delay     = 0
      options.leftovers = nil
       

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: example.rb [options]"
        opts.separator ""
        opts.separator "Specific options:"

        # Boolean switch.
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options.verbose = v
        end
        
        # Cast 'time' argument to an integer.
        opts.on("-t", "--time [TIME]", Integer, "Begin execution at given time") do |time|
          options.time = time
        end

        # Cast 'delay' argument to a Float.
        opts.on("--delay N", Float, "Delay N seconds before executing") do |n|
          options.delay = n
        end

         # List of arguments.
        opts.on("--list x,y,z", Array, "Example 'list' of arguments") do |list|
          options.list = list
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

  end  # class OptparseExample

  options = OptparseExample.parse(ARGV)
  pp options
  puts ""
  puts ""
  puts options.leftovers
  
  
