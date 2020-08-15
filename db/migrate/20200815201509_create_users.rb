class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.belongs_to :config, null: false, polymorphic: true
      t.timestamps
    end
  end
end
