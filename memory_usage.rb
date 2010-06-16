#!/usr/bin/env ruby

#Class which has function for gathering memory stats.
# Should work on unix/linux and OS X
# Example usage at the bottom
class Memory

   def initialize
      #Based on: http://gist.github.com/290988
      @total = 0.0
      @usage = Array.new
      @max = {:pid=>0, :rss=>0, :command=>0}

      `ps -u $USER -o pid,rss,command`.split("\n").each do |p|
         p.strip!
         if p.match(/^\d/) 
            p =~ /(\d+)\s+(\d+)\s+(.+)/
            
            pid, rss, command = [$1, $2, $3]
            rss = rss.to_f
            @usage << {:pid=>pid, :rss=>(rss/1024), :command=>command }
            @total += rss/1024

            if pid.to_s.size > @max[:pid]
               @max[:pid] = pid.to_s.size
            end

            if rss.to_s.size > @max[:rss]
               @max[:rss] = rss.to_s.size
            end
      
            if command.size > @max[:command]
               @max[:command] = command.size
            end
            #puts pid + (" %.2f MB " % (rss/1024)) + command
            
         end
      end
       @usage = @usage.sort_by { |process| process[:rss] }
      #puts "Your total usage: %.2f MB" % (total / 1024)
   end

   def report
      @usage.each do |x|
         #rjust string.rjust(min length)
         puts x[:pid].rjust( @max[:pid] ) + (" %.2f MB " % x[:rss]).rjust( @max[:rss]+3 ) + x[:command]
      end
      puts "Total Memory Usage: %.2f MB" % @total
   end

   def total
      "%.2f" % @total
   end
end

#Run example only if called directly
#ie not if included/required for class 
if $0 == __FILE__
   a = Memory.new
   a.report
   puts a.total
end
