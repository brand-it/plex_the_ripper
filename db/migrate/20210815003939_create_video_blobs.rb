class CreateVideoBlobs < ActiveRecord::Migration[6.1]
  def change
    create_table :video_blobs do |t|
      t.string     :key,          null: false
      t.string     :filename,     null: false
      t.string     :content_type, null: false
      t.text       :metadata
      t.string     :service_name, null: false
      t.bigint     :byte_size,    null: false
      t.boolean    :optimized,    null: false, default: false
      t.references :video,        polymorphic: true, index: true

      t.timestamps

      t.index [:key, :service_name], unique: true
    end
  end
end
