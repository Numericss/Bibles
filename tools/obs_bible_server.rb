#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "webrick"

DEFAULT_PORT = 8765

root = Pathname.new(ARGV[0] || Pathname.new(__dir__).parent).expand_path
port = Integer(ENV.fetch("OBS_BIBLE_PORT", DEFAULT_PORT), exception: false) || DEFAULT_PORT

unless root.join("obs-bible-plugin-dock", "index.html").file? &&
       root.join("obs-bible-plugin-browser", "index.html").file?
  warn "Could not find OBS Bible plugin files in: #{root}"
  exit 1
end

server = WEBrick::HTTPServer.new(
  BindAddress: "127.0.0.1",
  Port: port,
  DocumentRoot: root.to_s,
  DirectoryIndex: ["index.html"],
  AccessLog: [],
  Logger: WEBrick::Log.new($stderr, WEBrick::Log::WARN)
)

trap("INT") { server.shutdown }
trap("TERM") { server.shutdown }

puts "OBS Bible local server is running."
puts
puts "Use these in OBS:"
puts "Bible Dock URL:"
puts "http://127.0.0.1:#{port}/obs-bible-plugin-dock/index.html"
puts
puts "Bible Text Browser Source URL:"
puts "http://127.0.0.1:#{port}/obs-bible-plugin-browser/index.html"
puts
puts "Keep this window open while using the Bible dock in OBS." if $stdout.tty?
puts

server.start
