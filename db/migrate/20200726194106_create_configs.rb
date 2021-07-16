class CreateConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :configs do |t|
      t.string :type, null: false, default: 'Config'
      t.text :settings
      t.timestamps
    end
  end
end
