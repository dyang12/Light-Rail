class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    req.request_method.downcase == http_method && req.path.match(pattern)
  end

  def run(req, res)
    route_params = {}
    # /users\/(?<user_id>).*\/posts/(?<id>).*/ =~ "users/5"
    # id # => "5"
    m = /\d+/.match(req.path)
    route_params[:id] = m[0] unless m.nil?
    controller = controller_class.new(req, res, route_params)
    controller.invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(route)
    @routes << route
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    # Route.new(pattern, method, controller_class, action_name)
    # add these helpers in a loop here
    define_method(http_method) do |pattern, controller_class, action_name|
      route = Route.new(pattern, http_method.to_s, controller_class, action_name)
      add_route(route)
    end
  end

  def match(req)
    @routes.find do |route|
      route.matches?(req)
    end
    
    # nil
  end

  def run(req, res)
    route = match(req)
    route.nil? ? res.status = 404 : route.run(req, res)
  end
end
