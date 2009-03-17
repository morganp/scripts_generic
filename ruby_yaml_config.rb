#!/usr/bin/ruby -w

require 'yaml'

configFile = "config.yml"

#Function to save
def saveConfig(configFile, config)
  open(configFile, 'w') {|f| YAML.dump(config, f)}
end

#Function to Load Settings
def loadConfig(configFile)
   if File.exist?(configFile)
      config = open(configFile) {|f| YAML.load(f) }
   else
      config = {}
   end
   #do this to set parameters that might be missing from the yaml file
   if config[:raw_conf_folder_loc].nil?  
      config[:raw_conf_folder_loc] = "1"
   end
   if config[:drv_conf_folder_loc].nil?  
      config[:drv_conf_folder_loc] = "2"
   end
   return config
end

#Usage Examples
config = loadConfig(configFile)
saveConfig(configFile, config)

puts "Loaded Config Output"
puts config[:raw_conf_folder_loc]
puts config[:drv_conf_folder_loc]



