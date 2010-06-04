#!/usr/bin/env ruby

require 'pp'

# Hack to load local reliative files
path = File.expand_path $0
path = File.dirname(path)

require "#{path}/bencoding"

# handle arguments
if ARGV.length == 2
  puts "Usage: #{__FILE__} <torrent_file>"
  exit 1
end
  
torrentFile = ARGV[0]

torrent = Bencoding.new(torrentFile)
metainfo = torrent.metainfo

puts torrent


