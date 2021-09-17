class UpdatingAlerts < ActiveRecord::Migration[6.1]
  change_table :alerts do |t|
    t.rename :origin, :departure_city_name
    t.string :departure_city_url_name
    t.integer :departure_city_id
    t.rename :destination, :destination_city_name
    t.string :destination_city_url_name
    t.integer :destination_city_id
  end
end
