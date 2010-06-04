require 'pp'

class Bencoding

   #--------------PUBLIC METHODS--------------------------#
   public

   def initialize (file)
      #Global to pass data for the recursive calls
      # This is really bad but instance variables do not seem to work
      # TODO figure out how this can not be global
            
      # Prefom a little input verification, vaildate the input file
      @msg = "#{$0} \n\tSent #{ARGV[0]}  \n\t"
      if not File.file? file
         if File.directory? file
            puts @msg + "Input Requires Torrent File Not a Directoy"
         else
            puts  @msg + "File Does Not Exist"
         end
         exit 1
      end
      @file       = File.new(file)
      $file       = @file
      @metainfo   = Bencoding.bdecode()


      if metainfo.class.to_s != "Hash"
         puts @msg + "Invalid Torrent File"
         exit 1
      end
   end

   def metainfo
      return @metainfo
   end

   def to_s
      # output torrent information by reading the root dictionary (metainfo)
      output = "\n====== Torrent Information ======\n"
      # Get Tracker Information.
      # Two cases - Either there is an 'announce-list' key which lists multiple trackers,
      #             or there is an 'announce' key which has one tracker URL in it.
      output += "Tracker(s) \n"
      output += "------------------- \n"
      if metainfo['announce-list']
        metainfo['announce-list'].flatten.each do |tracker|
          output += "Tracker URL: \t" + tracker + "\n"
        end
      else
        output += "Tracker URL: \t" + metainfo['announce'] + "\n"
      end
      output += "\n"
      # Get File Information
      # Two cases - Either this is a Single File torrent, in which case there is 1 file.
      #             Or this is a Multi File torrent, in which case there is a directory
      #             and then a bunch of files.
      if metainfo['info']['files'].nil? # we have a Single File Torrent
        output += "Single File Torrent \n"
        output += "------------------- \n"
        output += "Filename: \t" + metainfo['info']['name'] + "\n"
        output += "File size: \t" + metainfo['info']['length'].to_s + "\n"
        output += "MD5 Sum: \t" + metainfo['info']['md5sum'] + "\n" if metainfo['info']['md5sum']
      else # we have Multi-File torrent
        output += "Multi File Torrent \n"
        output += "------------------- \n"
        output += "Directory: \t" + metainfo['info']['name'] + "\n\n"
        output += "Files \n"
        output += "------------------- \n"
        # output info for each file
        for file in metainfo['info']['files']
          output += "\n File path: \t \n\n"
          # File paths are stored in a list (array) of strings, one for each part of the path
          # e.g. Heroes/Season 1/Episode 1.avi is stored as ["Heroes", "Season 1", "Episode 1.avi"]
          for dir_piece in file['path']
            path += dir_piece + "/"
          end 
          output += path.chop # chop gets rid of extra trailing '/'
          output += "\n File size: \t" + file['length'].to_s
          output += "\n MD5 Sum: \t" + file['md5sum'] if file['md5sum']
        end
      end
      # Get Miscellaneous info.. basically just reading from dictionary and printing.
      output += "\n\nMiscellaneous Info\n"
      output += "-------------------\n"
      output += "Private: \t" + (metainfo['info']['private'] == 1).to_s + "\n" if metainfo['info']['private']
      output += "Piece Length: \t" + metainfo['info']['piece length'].to_s + "\n"
      output += "Created On: \t" + Time.at(metainfo['creation date']).to_s + "\n" if metainfo['creation date']
      output += "Created By: \t" + metainfo['created by'] + "\n" if metainfo['created by']
      output += "Comment: \t" + metainfo['comment'] + "\n" if metainfo['comment']
      output += "\n"

   end

  # recursive bdecode returns the first type it finds
  # However, if that type is List or Dictionary, it recursively fleshes out that type
  # In case of Torrent files, root element is one big Dictionary, so this essentially parses whole file
  def self.bdecode()
    # state variables
    string_start     = false  # beginning string state, meaning we are currently reading in string length
    string           = false  # string state (meaning we are currently reading in a string)
    string_remaining = 0      # how many more bytes of string we have
    list             = false  # list state
    integer          = false  # integer state
    dictionary       = false  # dictionary state
    cur_dict         = {}     # holds current dictionary
    cur_list         = []     # holds current list
    cur_string       = ""     # holds current string (also current integer, which is converted with .to_i at end)

    $file.each_byte do |byte|
      cur_string += byte.chr # only used by string and integer types, but it doesn't hurt to be in others

      ##### Strings have a special case where we need to parse  ######
      ##### out the length before we begin recording it         ######
      ##### Here we found : which means we have length and we   ######
      ##### are officially entering String state. Set vars appropriately. #####
      if string_start and byte.chr == ':'
        string = true
        string_start = false
        string_remaining = cur_string.to_i
        cur_string = ""

      ##### In String State, we decrement string_remaining each   #####
      ##### time so we know when to stop reading into string.     #####
      elsif string
        string_remaining -= 1

      ##### In Integer State, and encountered an 'e', so int is over #####
      elsif integer and byte.chr == 'e'
        cur_string.sub!(/e/,"") # get rid of e that was added to cur_string on this pass
        return cur_string.to_i # return as integer

      elsif integer and is_digit(byte)
        # do nothing, since above cur_string += byte.chr takes care of recording int byte-by-byte

      ##### In Dictionary State, and encountered an 'e', so dict is over. #####
      elsif dictionary and byte.chr == 'e' # dictionary is over on an 'e' character
        return cur_dict

      ##### In List State, and encountered an 'e', so list is over. #####
      elsif list and byte.chr == 'e' # list is over on an 'e' character
        return cur_list

      ##### In Dictionary State, and it's not over (No 'e'), so read #####
      ##### next key/value pair using recursive call to bdecode()    #####
      elsif dictionary
        # must reset file back 1 byte because after we got last key/value pair
        # of hash, we had to recycle through each_byte loop and read a byte 
        # that's part of next pair
        $file.seek(-1, IO::SEEK_CUR)
        key = bdecode()
        if key.class.to_s != "String"
          puts "Parse error: Dictionary has non-string key"
          exit
        end
        value = bdecode()
        cur_dict[key] = value

      ##### In List State, and it's not over (No 'e'), so read  next #####
      ##### element in list using recursive call to bdecode()        #####
      elsif list
        # must reset file back 1 byte because after we got last elem of list,
        # we had to recycle through each_byte loop and read a byte that's 
        # part of next list element
        $file.seek(-1, IO::SEEK_CUR)
        # get next element
        cur_list << bdecode()

      ######  getting to this point means we don't yet have a state       ######
      ######  start the state by seeing if it's a digit, 'i', 'd', or 'l' ######
      elsif is_digit(byte)
        # strings start with a digit
        # (we know it's not digit part of integer because integer == false)
        string_start = true

      elsif byte.chr == 'i'
        # start integer state
        integer = true
        cur_string = ""

      elsif byte.chr == 'd'
        # start dictionary state
        cur_dict = {}
        dictionary = true

      elsif byte.chr == 'l'
        # start list state
        cur_list = []
        list = true

      else
        # this should never happen, except at EOF if there is a stray newline
        # returning nil makes it so parent lists/dicts aren't affected
        return nil
      end
      # end string state after we read N bytes into cur_string
      # no other way to know that we're done string (since strings don't use "e" at end)
      # this can't be part of main if/elsif because otherwise we would get one extra byte
      if string and string_remaining == 0
        return cur_string
      end
    end
  end
  
  #-------------PRIVATE METHODS---------------------------#
  private
  # quick method to test if byte is a digit (0 - 9 in ASCII)
  def self.is_digit(byte)
    (byte.chr >= '0' and byte.chr <= '9')
  end
  
end # end class
