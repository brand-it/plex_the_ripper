# frozen_string_literal: true

class RipWorker < ApplicationWorker
  option :disk_title_ids, Types::Array.of(Types::Integer)

  def call
    disk_titles.map do |title|
      create_mkv(title).tap do |result|
        result.mkv_path = RenameMkvService.new(disk_title: title, result: result).call
      end
    end
  end

  private

  def create_mkv(title)
    CreateMkvService.new(disk_title: title, progress_listener: MkvProgressListener.new).call
  end

  def disk_titles
    @disk_titles ||= DiskTitle.where(id: disk_title_ids)
  end
end
