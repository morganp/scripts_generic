#!/usr/bin/ruby -w

require 'yaml'

configFile = "config.yml"

#Function to save
def saveConfig(configFile, config)
   #For Shoes compatability change to a known directory
   Dir.chdir(ENV['HOME'])
   open(configFile, 'w') {|f| YAML.dump(config, f)}
end

#Function to Load Settings
def loadConfig(configFile)
   #For Shoes compatability change to a known directory
   Dir.chdir(ENV['HOME'])
   config = {}
   #do this to set parameters that might be missing from the yaml file
   config[:raw_conf_folder_loc] = "1"
   config[:drv_conf_folder_loc] = "2"
   if File.exist?(configFile)
      config.update(open(configFile) {|f| YAML.load(f) })
   end
   return config
end

#Usage Examples
config = loadConfig(configFile)
saveConfig(configFile, config)

puts "Loaded Config Output"
puts config[:raw_conf_folder_loc]
puts config[:drv_conf_folder_loc]



