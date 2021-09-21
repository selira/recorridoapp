class AddDoubleIndexToBusTravel < ActiveRecord::Migration[6.1]
  def change
    add_index :bus_travels, [:alert_id, :date], unique: true
  end
end