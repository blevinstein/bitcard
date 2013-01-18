require 'net/http'
require 'uri'
require 'json'
require 'pp'

class BitcoinRPC
  def initialize(service_url)
    @uri = URI.parse(service_url)
  end

  def method_missing(name, *args)
    post_body = {:method => name,
                 :params => args,
                 :id => 'jsonrpc'}.to_json
    resp = JSON.parse( http_post_request(post_body) )
    raise JSONRPCError, resp['error'] if resp['error']
    resp['result']
  end

  def http_post_request(post_body)
    http = Net::HTTP.new(@uri.host, @uri.port)
    request = Net::HTTP::Post.new(@uri.request_uri)
    request.basic_auth @uri.user, @uri.password
    request.content_type = 'application/json'
    request.body = post_body
    http.request(request).body
  end

  class JSONRPCError < RuntimeError; end
end

if $0 == __FILE__
  user = 'bitcoinrpc'
  pass = 'be3189b6-242e-49d5-af91-1c94463dd903'
  #host = '127.0.0.1'
  host = '10.0.0.2'
  port = 8332
  rpc = BitcoinRPC.new("http://#{user}:#{pass}@#{host}:#{port}")
  while true
    print '> '
    command = gets.split.map do |arg|
      case arg
      when /true/i
        true
      when /false/i
        false
      when /-?\d+/
        arg.to_i
      when /-?\d*\.\d+/
        arg.to_f
      else
        arg
      end
    end
    pp rpc.send(*command)
  end
end

