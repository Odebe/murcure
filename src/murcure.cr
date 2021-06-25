require "option_parser"

require "socket"
require "openssl"
require "bindata"
require "aasm"
require "earl"
require "rwlock"

require "../lib/earl/src/artist.cr"
require "../lib/earl/src/agent.cr"

require "./murcure/server"

module Murcure
  VERSION = "0.1.0"
end

host = "0.0.0.0"
port = 64738_u32
private_key = "key.pem"
certificate_chain = "cert.pem"

OptionParser.parse do |parser|
  parser.banner = "Usage: murcure -p 64738 -k key.pem -c cert.pem"

  parser.on("-p PORT", "--port=PORT", "port") do |par_port| 
    port = par_port.to_u32
  end

  parser.on("-k KEY_PATH", "--key=KEY_PATH", "ssl server private key") do |key_path| 
    unless File.exists?(key_path)
      STDERR.puts "ERROR: key_path not found"
      STDERR.puts parser
      exit(1)
    end

    private_key = key_path
  end

  parser.on("-c CERT_PATH", "--cert=CERT_PATH", "ssl server cert") do |cert_path| 
    unless File.exists?(cert_path)
      STDERR.puts "ERROR: cert_path not found"
      STDERR.puts parser
      exit(1)
    end

    certificate_chain = cert_path
  end

  parser.on("-v", "--version", "Show version") do
    puts "Murcure #{Murcure::VERSION}"
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

ssl_context = OpenSSL::SSL::Context::Server.new
ssl_context.private_key = private_key
ssl_context.certificate_chain = certificate_chain

# TODO: Murcure::Config
server = Murcure::NewServer.new(host, port, ssl_context)
server.start!

sleep
