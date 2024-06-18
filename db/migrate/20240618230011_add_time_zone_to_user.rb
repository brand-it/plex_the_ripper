class AddTimeZoneToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :time_zone, :string, null: false, limit: 255, default: "Pacific Time (US & Canada)"
  end
end
