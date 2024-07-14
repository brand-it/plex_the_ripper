class BackfillExtraTypeNumber < ActiveRecord::Migration[7.1]
  def change
    VideoBlob.all.each do |blob|
      blob.extra_type_number = VideoBlob.where(episode:, video:, extra_type:)
                                        .pluck(:extra_type_number).max.to_i + 1
      blob.save!
    end
  end
end
