class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.references :report, :null => false
      t.text :caption
      t.string :image_id, :limit => 100, :null => false
      t.string :image_filename, :limit => 255, :null => false
      t.integer :image_size, :limit => 4, :null => false
      t.string :image_content_type, :limit => 255, :null => false
      t.datetime :taken_at
      t.decimal :latitude, :precision => 10, :scale => 7
      t.decimal :longitude, :precision => 10, :scale => 7
      t.decimal :altitude, :precision => 12, :scale => 7
      t.decimal :image_direction, :precision => 10, :scale => 7
      t.timestamps :null => false
    end
  end
end
