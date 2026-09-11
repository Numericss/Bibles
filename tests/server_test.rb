# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "socket"
require "rbconfig"
require_relative "../tools/server_config"

class ServerTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def setup
    socket = TCPServer.new("127.0.0.1", 0)
    @port = socket.addr[1]
    socket.close
    @pid = Process.spawn({ "OBS_BIBLE_PORT" => @port.to_s }, RbConfig.ruby,
                         File.join(ROOT, "tools/obs_bible_server.rb"), ROOT,
                         out: File::NULL, err: File::NULL)
    100.times do
      break if BibleServer.ready?(@port)
      sleep 0.05
    end
    assert BibleServer.ready?(@port), "test server did not start"
  end

  def teardown
    Process.kill("TERM", @pid)
    Process.wait(@pid)
  rescue Errno::ESRCH, Errno::ECHILD
    nil
  end

  def get(path)
    Net::HTTP.new("127.0.0.1", @port, nil).get(path)
  end

  def test_root_redirects_to_dock
    response = get("/")
    assert_equal "302", response.code
    assert_equal "/obs-bible-plugin-dock/index.html", URI(response["Location"]).path
  end

  def test_assets_and_health
    %w[obs-bible-plugin-dock/index.html obs-bible-plugin-browser/index.html obs-bible-plugin-browser/main.js].each do |path|
      assert_equal "200", get("/#{path}").code
    end
    assert_equal BibleServer::HEALTH_BODY, get("/healthz").body
    assert_equal "no-store", get("/healthz")["Cache-Control"]
  end

  def test_repository_and_unknown_paths_are_not_served
    %w[/README.md /.git/config /tools/obs_bible_server.rb /healthz/extra /missing].each do |path|
      assert_equal "404", get(path).code, path
    end
  end

  def test_urls_honor_custom_port_and_exclude_file_urls
    output, status = Open3.capture2({ "OBS_BIBLE_PORT" => @port.to_s }, RbConfig.ruby,
                                  File.join(ROOT, "tools/print_urls.rb"))
    assert status.success?
    assert_includes output, "http://127.0.0.1:#{@port}/obs-bible-plugin-dock/index.html"
    refute_includes output, "file://"
  end

  def test_invalid_ports_fail_clearly
    %w[0 65536 invalid].each do |value|
      output, status = Open3.capture2e({ "OBS_BIBLE_PORT" => value }, RbConfig.ruby,
                                     File.join(ROOT, "tools/server_config.rb"))
      refute status.success?
      assert_includes output, "between 1 and 65535"
    end
  end

  def test_an_unrelated_http_server_is_not_ready
    listener = TCPServer.new("127.0.0.1", 0)
    thread = Thread.new do
      client = listener.accept
      client.gets
      client.write "HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nOK"
      client.close
    end
    refute BibleServer.ready?(listener.addr[1])
    thread.join
  ensure
    listener&.close
  end
end
