#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "uri"

root = Pathname.new(ARGV[0] || Pathname.new(__dir__).parent).expand_path
dock = root.join("obs-bible-plugin-dock", "index.html")
browser = root.join("obs-bible-plugin-browser", "index.html")
port = Integer(ENV.fetch("OBS_BIBLE_PORT", 8765), exception: false) || 8765

def file_url(path)
  URI::DEFAULT_PARSER.escape("file://#{path.expand_path}")
end

puts "Bible Dock URL:"
puts file_url(dock)
puts
puts "Browser Source local file:"
puts browser.expand_path
puts
puts "Browser Source URL:"
puts file_url(browser)
puts
puts "Recommended macOS local server URLs:"
puts "Bible Dock URL:"
puts "http://127.0.0.1:#{port}/obs-bible-plugin-dock/index.html"
puts
puts "Bible Text Browser Source URL:"
puts "http://127.0.0.1:#{port}/obs-bible-plugin-browser/index.html"
