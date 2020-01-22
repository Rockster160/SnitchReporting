# SnitchReporting
Snitch Reporting adds middleware to your Rails app to automatically track errors.
This is a self-hosted gem that plugs directly into your app.

## Usage
Install the gem, run the migrations, add to your middleware, then mount the route to view. Let the gem find and track your bugs for you!

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'snitch_reporting'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install snitch_reporting
```

Add the migrations to your app with
```bash
rails g snitch_reporting:install
rails db:migrate
```

Add the middleware to your app by including the following in your application.rb
```ruby
Rails.application.config.middleware.use SnitchReporting::Rack, ->(occurrence) {
  # Use the `occurrence` and `occurrence.report` to retrieve the info and notify to your reception box of choice, whether it be Email, SMS, Slack, or some other API.
}
```

## Contributing
Lots of things to do, and would love some PRs! Feel free to pull the code down and submit a PR with some changes.
A few things I'd like to do:

- [] Track/display how many unique users are affected by the error
- [] Visually graph history of the error
- [] Add commenting capabilities
- [] Track history of changes, whether they be marking as resolved, commenting, etc.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
