require "snitch_reporting"
require "snitch_reporting/engine"
require "snitch_reporting/rack"
require "snitch_reporting/version"

module SnitchReporting
  def self.report(log_level, *args)
    ::SnitchReporting::SnitchReport.report(log_level, args)
  end
end
