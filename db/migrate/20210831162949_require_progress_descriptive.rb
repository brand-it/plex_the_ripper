class RequireProgressDescriptive < ActiveRecord::Migration[6.1]
  def change
    change_column_null :progresses, :descriptive, false
  end
end
