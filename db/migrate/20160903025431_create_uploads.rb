class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :uuid, :limit => 36, :null => false
      t.string :file_id, :limit => 100, :null => false
      t.string :file_filename, :limit => 255, :null => false
      t.integer :file_size, :limit => 4, :null => false
      t.string :file_content_type, :limit => 255, :null => false
      t.timestamps :null => false
      t.integer :creator_id
      t.integer :updater_id
    end

    add_index(:uploads, :uuid, :unique => true)
  end
end
