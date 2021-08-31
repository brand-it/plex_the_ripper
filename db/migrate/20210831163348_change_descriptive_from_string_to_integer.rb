class ChangeDescriptiveFromStringToInteger < ActiveRecord::Migration[6.1]
  def up
    remove_column :progresses, :descriptive
    add_column :progresses, :descriptive, :integer, null: false, default: 0
  end

  def down
    remove_column :progresses, :descriptive
    add_column :progresses, :descriptive, :string
  end
end
