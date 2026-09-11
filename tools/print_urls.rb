#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "server_config"
port = BibleServer.port

puts "In OBS, leave Local file unchecked and use these URLs:"
puts
puts "Bible Dock URL:"
puts "http://127.0.0.1:#{port}/obs-bible-plugin-dock/index.html"
puts
puts "Bible Text Browser Source URL:"
puts "http://127.0.0.1:#{port}/obs-bible-plugin-browser/index.html"
puts
puts "Both must use the same address and port so the dock can control the overlay."
