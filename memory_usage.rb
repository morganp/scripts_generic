#!/usr/bin/env ruby


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
         puts pad_start(@max[:pid], x[:pid]) + pad_start(@max[:rss]+3 ,(" %.2f MB " % x[:rss])) + x[:command]
      end
      puts "Total Memory Usage: %.2f MB" % @total
   end

   def total
      "%.2f" % @total
   end

   def pad_start(x, text)
      answer = ""
      if text.size < x
         for y in 0...(x-text.size)
            answer = " " + answer
         end
      end
      return answer + text
   end

end

a = Memory.new
a.report
