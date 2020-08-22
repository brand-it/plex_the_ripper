# frozen_string_literal: true

class Tv < ApplicationRecord
  include DiskWorkflow
  include Wisper::Publisher
  with_options unless: :the_movie_db_id do
    validates :name, presence: true
    validates :original_name, presence: true
  end

  has_many :seasons
end
