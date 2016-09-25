class CarrierwaveForUploads < ActiveRecord::Migration
  def up
    create_table :carrierwave_files do |t|
      t.string :path, :null => false
      t.column :pg_largeobject_oid, :oid, :null => false
      t.integer :size, :null => false
      t.string :content_type
      t.timestamps(:null => false)
    end
    add_index :carrierwave_files, :path, :unique => true

    Photo.with_deleted.all.each do |photo|
      refile = select_one("SELECT * FROM refile_attachments WHERE oid = #{photo["original_image_id"]}")
      if(!refile)
        puts "WARNING: No refile found for #{photo.inspect}"
        execute("DELETE FROM #{Photo.table_name} WHERE id = #{photo.id}")
        next
      end

      path = "uploads/#{photo.class.to_s.underscore}/image/#{photo.id}/#{photo["original_image_filename"]}"
      time = Time.now.utc
      execute("INSERT INTO carrierwave_files(path, pg_largeobject_oid, content_type, size, created_at, updated_at) VALUES('#{path}', #{refile["oid"]}, #{quote(photo["original_image_content_type"])}, #{photo["original_image_size"]}, #{quote(refile["created_at"])}, #{quote(refile["created_at"])})")
      execute("DELETE FROM refile_attachments WHERE oid = #{photo["image_id"]}")
      execute("DELETE FROM refile_attachments WHERE oid = #{photo["original_image_id"]}")
    end

    Upload.all.each do |upload|
      refile = select_one("SELECT * FROM refile_attachments WHERE oid = #{upload["file_id"]}")
      if(!refile)
        puts "WARNING: No refile found for #{upload.inspect}"
        execute("DELETE FROM #{Upload.table_name} WHERE id = #{upload.id}")
        next
      end

      path = "uploads/#{upload.class.to_s.underscore}/file/#{upload.id}/#{upload["file_filename"]}"
      execute("INSERT INTO carrierwave_files(path, pg_largeobject_oid, content_type, size, created_at, updated_at) VALUES('#{path}', #{refile["oid"]}, #{quote(upload["file_content_type"])}, #{upload["file_size"]}, #{quote(refile["created_at"])}, #{quote(refile["created_at"])})")
      execute("DELETE FROM refile_attachments WHERE oid = #{upload["file_id"]}")
    end

    remaining = Integer(select_value("SELECT COUNT(*) FROM refile_attachments"))
    if(remaining != 0)
      raise "Still refile attachment records remaining"
    end

    remove_column :photos, :image_id
    remove_column :photos, :image_filename
    remove_column :photos, :image_size
    remove_column :photos, :image_content_type
    remove_column :photos, :original_image_id
    rename_column :photos, :original_image_filename, :image
    rename_column :photos, :original_image_size, :image_size
    rename_column :photos, :original_image_content_type, :image_content_type

    remove_column :uploads, :file_id
    rename_column :uploads, :file_filename, :file

    Photo.with_deleted.all.each do |photo|
      puts "Recreating versions for photo #{photo.id}..."
      photo.image.recreate_versions!
    end
  end

  def down
    drop_table :carrierwave_files
    remove_column :photos, :image
    remove_column :uploads, :file
  end
end
