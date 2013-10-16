require 'uri'

class Params
  def initialize(req, route_params)
    @params = {}
    parse_request_body(req.body) unless req.body.nil?
    parse_www_encoded_form(req.query_string) unless req.query_string.nil?
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    decoded_www = URI.decode_www_form(www_encoded_form)
    decoded_www.each do |(key, value)|
      @params[key] = value
    end
  end
  
  def parse_request_body(request_body)
    decoded_body = URI.decode_www_form(request_body)
    decoded_body.each do |(key, value)|
      keys = key.scan(/\w+/)
      if @params[keys[0]].nil?
        @params[keys[0]] = {keys[1] => value}
        p @params
      else
        @params[keys[0]] = @params[keys[0]].merge({keys[1] => value})
      end
    end
  end
end
