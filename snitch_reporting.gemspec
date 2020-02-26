$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "snitch_reporting/version"
# To Release:
# Run: updateGem <version>

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "snitch_reporting"
  spec.version     = SnitchReporting::VERSION
  spec.authors     = ["Rocco Nicholls"]
  spec.email       = ["support@ardesian.com"]
  spec.homepage    = "https://github.com/Rockster160/SnitchReporting"
  spec.summary     = "Adds a localized error reporting/tracking system."
  spec.description = "Tracks errors using middleware and provides an interface in order to view and track the errors."
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 5.0.0"
  spec.add_dependency "kaminari"
  spec.add_dependency "sass-rails"
  # spec.add_dependency "pry-rails"

  spec.add_development_dependency "pg"
end
