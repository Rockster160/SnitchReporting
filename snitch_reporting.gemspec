$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "snitch_reporting/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "snitch_reporting"
  spec.version     = SnitchReporting::VERSION
  spec.authors     = ["Rocco Nicholls"]
  spec.email       = ["support@ardesian.com"]
  spec.homepage    = "https://github.com/Rockster160/SnitchReporting"
  spec.summary     = "Adds a localized error reporting/tracking system."
  spec.description = "Tracks errors using a middle man and provides an interface in order to interact and view the errors."
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.3"
  spec.add_dependency "kaminari"
  spec.add_dependency "sass-rails"

  spec.add_development_dependency "pg"
end
