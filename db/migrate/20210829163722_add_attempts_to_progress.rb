class AddAttemptsToProgress < ActiveRecord::Migration[6.1]
  def change
    add_column :progresses, :attempts, :integer, default: 0, null: false
  end
end
