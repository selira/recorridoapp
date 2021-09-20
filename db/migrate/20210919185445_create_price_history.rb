class CreatePriceHistory < ActiveRecord::Migration[6.1]
  def change
    create_table :price_histories do |t|
      t.belongs_to :alert, foreign_key: true
      t.float :price
      t.timestamps 
    end
  end
end
