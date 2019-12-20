# belongs_to :snitch_report
# belongs_to :author
# text :body
class SnitchReporting::SnitchComment < ApplicationRecord
  belongs_to :snitch_report
  belongs_to :author, optional: true
end
