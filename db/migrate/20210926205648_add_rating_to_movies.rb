class AddRatingToMovies < ActiveRecord::Migration[6.1]
  def change
    add_column :videos, :rating, :integer, default: 0, null: false
  end
end
