require 'uri'

class Params
  def initialize(req, route_params)
    @params = route_params unless route_params.nil?
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
      keys = parse_key(key)
      primary_key = keys.shift
      if @params[primary_key].nil?
        @params[primary_key] = deep_setter(keys, value)
      else
        @params[primary_key] = deep_merge(@params[primary_key], deep_setter(keys, value))
      end
    end
  end

  def parse_key(key)
    key.scan(/\w+/)
  end

  
  def deep_setter(keys, value)
    if keys.length == 1
      return { keys[0] => value }
    else
      temp_hash = { keys.pop => value }
      deep_setter(keys, temp_hash)
    end
  end
  
  def deep_merge(hash1, hash2)
    #merges nested hashes
    hash1.merge(hash2)
  end
end
