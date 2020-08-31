# frozen_string_literal: true

class Disk < ApplicationRecord
  has_many :disk_titles, dependent: :destroy
  has_many :episodes, dependent: :nullify

  before_update :destroy_disk_titles, if: :disk_name_changed?

  private

  def destroy_disk_titles
    disk_titles.destroy_all
  end
end
