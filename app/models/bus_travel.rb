class BusTravel < ApplicationRecord
    belongs_to :alert
    validates :date, uniqueness: { scope: :alert_id }
end