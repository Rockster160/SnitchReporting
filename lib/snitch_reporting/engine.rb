module SnitchReporting
  class Engine < ::Rails::Engine
    isolate_namespace SnitchReporting

    # config.app_middleware.use ::SnitchReporting::Rack
  end
end
