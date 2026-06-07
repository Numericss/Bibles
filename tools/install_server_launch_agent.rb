#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "fileutils"
require "pathname"
require "socket"

LABEL = "com.numericss.obs-bible-server"
PORT = 8765

root = Pathname.new(ARGV[0] || Pathname.new(__dir__).parent).expand_path
script = root.join("tools", "obs_bible_server.rb")
plist = Pathname.new("~/Library/LaunchAgents/#{LABEL}.plist").expand_path
uid = Process.uid

unless script.file?
  warn "Could not find Bible server script: #{script}"
  exit 1
end

FileUtils.mkdir_p(plist.dirname)

def x(value)
  CGI.escapeHTML(value.to_s)
end

plist.write(<<~XML)
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
    <key>Label</key>
    <string>#{x(LABEL)}</string>

    <key>ProgramArguments</key>
    <array>
      <string>/usr/bin/ruby</string>
      <string>#{x(script)}</string>
      <string>#{x(root)}</string>
    </array>

    <key>EnvironmentVariables</key>
    <dict>
      <key>OBS_BIBLE_PORT</key>
      <string>#{PORT}</string>
    </dict>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>#{x(root.join("server.out.log"))}</string>

    <key>StandardErrorPath</key>
    <string>#{x(root.join("server.err.log"))}</string>
  </dict>
  </plist>
XML

domain = "gui/#{uid}"
service = "#{domain}/#{LABEL}"

def service_loaded?(service)
  system("launchctl", "print", service, out: File::NULL, err: File::NULL)
end

def port_open?(port)
  socket = TCPSocket.new("127.0.0.1", port)
  socket.close
  true
rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
  false
end

system("launchctl", "bootout", service, out: File::NULL, err: File::NULL)
sleep 1

loaded = false
3.times do
  if service_loaded?(service) || system("launchctl", "bootstrap", domain, plist.to_s, out: File::NULL, err: File::NULL)
    loaded = true
    break
  end
  sleep 1
end

unless loaded || service_loaded?(service)
  warn "Could not load #{LABEL}. You can still double-click Start OBS Bible Server.command."
  exit 1
end

system("launchctl", "kickstart", "-k", service, out: File::NULL, err: File::NULL)

10.times do
  break if port_open?(PORT)

  sleep 0.5
end

puts "OBS Bible local server service is installed and running."
puts "Bible Dock URL:"
puts "http://127.0.0.1:#{PORT}/obs-bible-plugin-dock/index.html"
puts
puts "Bible Text Browser Source URL:"
puts "http://127.0.0.1:#{PORT}/obs-bible-plugin-browser/index.html"
