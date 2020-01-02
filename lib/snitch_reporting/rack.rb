class SnitchReporting::Rack
  class SnitchException < RuntimeError; end

  def initialize(app, opts={})
    @app = app
  end

  def call(env)
    response = @app.call(env)
    _, headers, = response

    if headers["X-Cascade"] == "pass"
      msg = "This exception means that the preceding Rack middleware set the 'X-Cascade' header to 'pass' -- in " \
      "Rails, this often means that the route was not found (404 error)."
      raise SnitchException, msg
    end

    response
  rescue Exception => exception
    ::SnitchReporting::SnitchReport.fatal(exception, env: env)

    raise exception unless exception.is_a?(SnitchException)

    response
  end
end
