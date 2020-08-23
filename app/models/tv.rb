# frozen_string_literal: true

class Tv < ApplicationRecord
  include DiskWorkflow
  include Wisper::Publisher

  serialize :episode_run_time, Array

  with_options unless: :the_movie_db_id do
    validates :name, presence: true
    validates :original_name, presence: true
  end

  has_many :seasons

  before_save { broadcast(:tv_saving, self) }
  after_commit { broadcast(:tv_saved, id, async: true) }
end
