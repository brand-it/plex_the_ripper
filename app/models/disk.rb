# frozen_string_literal: true

class Disk < ApplicationRecord
  has_many :disk_titles, dependent: :destroy
  has_many :episodes, dependent: :nullify

  before_update :destroy_disk_titles, if: :disk_name_changed?

  def self.all_valid?
    Rails.cache.fetch(Disk.all.cache_key, namespace: 'v1/all_valid', expires_in: 1.minute) do
      Disk.all.pluck(:disk_name) == ListDrivesService.new.call
    end
  end

  private

  def destroy_disk_titles
    disk_titles.destroy_all
  end
end
