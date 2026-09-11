# frozen_string_literal: true

require "net/http"
require "uri"

module BibleServer
  HEALTH_BODY = "obs-bible-server:ok\n".freeze

  def self.port
    value = Integer(ENV.fetch("OBS_BIBLE_PORT", "8765"), exception: false)
    abort "OBS_BIBLE_PORT must be a number between 1 and 65535." unless value && (1..65535).cover?(value)
    value
  end

  def self.ready?(port)
    http = Net::HTTP.new("127.0.0.1", port, nil)
    http.open_timeout = 1
    http.read_timeout = 1
    response = http.get("/healthz")
    response.code == "200" && response.body == HEALTH_BODY
  rescue SystemCallError, IOError, Timeout::Error, Net::HTTPBadResponse, EOFError
    false
  end
end

if $PROGRAM_NAME == __FILE__
  if ARGV.first == "--check"
    exit(BibleServer.ready?(BibleServer.port) ? 0 : 1)
  else
    puts BibleServer.port
  end
end
