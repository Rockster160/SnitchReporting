# belongs_to :snitch_report
# date :date
# bigint :count

class SnitchReporting::SnitchTracker < ApplicationRecord
  belongs_to :report, class_name: "SnitchReporting::SnitchReport"

  def self.tracker_for_date(date=nil)
    date ||= Date.today

    find_or_create_by(date: date)
  end

  # def self.count_for_date_range(start, end)
  #   where(date: start..end).sum(:count)
  # end
end
