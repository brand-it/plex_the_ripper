# frozen_string_literal: true

class Season < ApplicationRecord
  include Wisper::Publisher

  has_many :episodes
  belongs_to :tv

  before_save { broadcast(:season_saving, self) }
  after_commit { broadcast(:season_saved, id, async: true) }
end
