class CreateBusTravels < ActiveRecord::Migration[6.1]
  def change
    create_table :bus_travels do |t|

      t.string :date
      t.string :time
      t.integer :bus_category
      t.float :price
      t.string :company
      t.belongs_to :alert, foreign_key: true
      t.index :date
      t.timestamps

    end
  end
end
