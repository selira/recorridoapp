class CreateAlerts < ActiveRecord::Migration[6.1]
  def change
    create_table :alerts do |t|
      t.string :name
      t.string :origin
      t.string :destination
      t.integer :price
      t.integer :bus_category

      t.timestamps
    end
  end
end
