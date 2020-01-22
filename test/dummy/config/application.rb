require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require "snitch_reporting"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

Rails.application.config.middleware.use SnitchReporting::Rack, ->(occurrence) {
  # Use the `occurrence` and `occurrence.report` to retrieve the info and notify to your reception box of choice, whether it be Email, SMS, Slack, or some other API.
}
