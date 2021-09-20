class Alert < ApplicationRecord
    has_many :bus_travels
    has_many :price_histories
    #0: cualquiera, 1:premium, etc
    #enum bus_category: [:any, :premium, :salon_cama, :semi_cama, :pullman]
end
