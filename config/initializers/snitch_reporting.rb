::SnitchReporting::SnitchReport.log_levels.symbolize_keys.keys.each do |log_level|
  ::SnitchReporting.define_singleton_method(log_level) do |*args|
    ::SnitchReporting::SnitchReport.report(log_level, args)
  end
end
