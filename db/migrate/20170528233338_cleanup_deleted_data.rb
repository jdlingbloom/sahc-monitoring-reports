class CleanupDeletedData < ActiveRecord::Migration
  def up
    Report.only_deleted.each do |report|
      if report.deleted_at
        puts "Permanently deleting: #{report.inspect}"
        report.really_destroy!
      else
        raise "Unexpected record not deleted: #{report.inspect}"
      end
    end

    Photo.only_deleted.each do |photo|
      if photo.deleted_at
        puts "Permanently deleting: #{photo.inspect}"
        photo.really_destroy!
      else
        raise "Unexpected record not deleted: #{photo.inspect}"
      end
    end

    Photo.all.each do |photo|
      if(photo.image && !photo.image.file.exists?)
        puts "Photo image is missing, permanently deleting: #{photo.inspect} #{photo.image.inspect}"
        photo.really_destroy!
      end
    end
  end

  def down
  end
end
