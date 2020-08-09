class CreateConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :configs do |t|
      t.string :for, null: false
      t.text :settings
      t.timestamps
    end
  end
end
