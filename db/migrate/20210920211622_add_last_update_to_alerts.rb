class AddLastUpdateToAlerts < ActiveRecord::Migration[6.1]
  def change
    add_column :alerts, :last_update, :datetime
  end
end
