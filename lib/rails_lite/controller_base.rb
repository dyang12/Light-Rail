require 'erb'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params = nil)
    @request = req
    @response = res
    @already_built_response = false
    @params = Params.new(@request, route_params)
  end

  def session
    @session ||= Session.new(@request)
  end

  def already_rendered?
    @already_built_response
  end

  def redirect_to(url)
    if already_rendered?
      # raise DoubleRenderError, "can't render or redirect twice"
    else
      @response.status = 302
      @response['location'] = url
      session.store_session(@response)
      @already_built_response = true
    end
  end

  def render_content(content, type)
    unless already_rendered?
      @response.content_type = type
      @response.body = content
      session.store_session(@response)
      @already_built_response = true
    end
    
  end

  def render(template_name)
    # filename = template_for(template_name)
    file = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    template = ERB.new(file)
    render_content(template.result(binding), "text/html")
  end

  def invoke_action(name)
    self.send(name)
    
    unless already_rendered?
      render name
    end
  end
end
