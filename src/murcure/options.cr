require "option_parser"
require "./versions"

module Murcure
  module Options
    extend self

    def parse!
      OptionParser.parse do |parser|
        parser.banner = "Usage: murcure"
      
        parser.on("-v", "--version", "Show version") do
          puts "murcure #{Murcure::MURCURE_VER}, supperted mumble #{Murcure::MUMBLE_VER}"
          exit
        end
      
        parser.on("-h", "--help", "Show this help") do
          puts parser
          exit
        end
      
        parser.invalid_option do |flag|
          STDERR.puts "ERROR: #{flag} is not a valid option."
          STDERR.puts parser
          exit(1)
        end
      end
    end 
  end
end
