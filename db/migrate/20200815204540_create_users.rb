class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.belongs_to :config, polymorphic: true, null: false
      t.timestamps
    end
  end
end
