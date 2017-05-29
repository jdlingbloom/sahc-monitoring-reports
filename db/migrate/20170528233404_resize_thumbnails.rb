class ResizeThumbnails < ActiveRecord::Migration
  def up
    photos = Photo.with_deleted.all
    photo_count = photos.count
    i = 1
    photos.each do |photo|
      puts "#{i}/#{photo_count}: #{photo.id}"

      # Need to cache stored files, or else the thumbnail seems to be based on
      # the original image, rather than the "default" image (which is auto
      # oriented).
      photo.image.cache_stored_file!

      photo.image.recreate_versions!(:thumbnail)
      photo.save!
      i += 1
    end
  end

  def down
  end
end
