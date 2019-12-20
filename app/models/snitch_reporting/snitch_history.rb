# belongs_to :snitch_report
# belongs_to :user
# text :text
class SnitchReporting::SnitchHistory < ApplicationRecord
  belongs_to :snitch_report
  belongs_to :user, optional: true
end
