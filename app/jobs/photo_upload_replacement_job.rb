class PhotoUploadReplacementJob < ApplicationJob
  def perform(photo_id, upload_uuid, current_user_id)
    Upload.transaction do
      begin
        photo = Photo.find(photo_id)

        original_stamper = ActiveRecord::Userstamp.config.default_stamper_class.stamper
        ActiveRecord::Userstamp.config.default_stamper_class.stamper = current_user_id

        upload = Upload.find_by!(:uuid => upload_uuid)
        new_photo = upload.build_photos.first
        photo.image = new_photo.image
        photo.taken_at = new_photo.taken_at
        photo.latitude = new_photo.latitude
        photo.longitude = new_photo.longitude
        photo.altitude = new_photo.altitude
        photo.image_direction = new_photo.image_direction
        if(photo.caption.blank? && new_photo.caption.present?)
          photo.caption = new_photo.caption
        end
        upload.destroy

        photo.save!
        photo.report.update_column(:upload_progress, nil)
      rescue => e
        if photo
          photo.report.update_column(:upload_progress, "failure")
        end

        raise e
      ensure
        if original_stamper
          ActiveRecord::Userstamp.config.default_stamper_class.stamper = original_stamper
        end
      end
    end
  end
end
