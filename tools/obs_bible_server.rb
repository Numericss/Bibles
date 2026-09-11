#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "webrick"
require_relative "server_config"

root = Pathname.new(ARGV[0] || Pathname.new(__dir__).parent).expand_path
port = BibleServer.port

unless root.join("obs-bible-plugin-dock", "index.html").file? &&
       root.join("obs-bible-plugin-browser", "index.html").file?
  warn "Could not find OBS Bible plugin files in: #{root}"
  exit 1
end

server = WEBrick::HTTPServer.new(
  BindAddress: "127.0.0.1",
  Port: port,
  DirectoryIndex: ["index.html"],
  AccessLog: [],
  Logger: WEBrick::Log.new($stderr, WEBrick::Log::WARN)
)

# Serve only the two plugin folders, not repository files or server logs.
%w[obs-bible-plugin-dock obs-bible-plugin-browser].each do |folder|
  server.mount("/#{folder}", WEBrick::HTTPServlet::FileHandler, root.join(folder).to_s,
               FancyIndexing: false)
end
server.mount_proc("/healthz") do |request, response|
  raise WEBrick::HTTPStatus::NotFound unless request.path == "/healthz"
  response["Content-Type"] = "text/plain; charset=utf-8"
  response["Cache-Control"] = "no-store"
  response.body = BibleServer::HEALTH_BODY
end
server.mount_proc("/") do |request, response|
  raise WEBrick::HTTPStatus::NotFound unless request.path == "/"
  response.status = 302
  response["Location"] = "/obs-bible-plugin-dock/index.html"
end

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
