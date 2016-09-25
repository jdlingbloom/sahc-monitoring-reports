class PhotoUploadReplacementJob
  def initialize(photo_id, upload_uuid)
    @photo_id = photo_id
    @upload_uuid = upload_uuid
  end

  def perform
    Upload.transaction do
      photo = Photo.find(@photo_id)
      upload = Upload.find_by!(:uuid => @upload_uuid)
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
    end
  end

  def failure
    photo = Photo.find(@photo_id)
    photo.report.update_column(:upload_progress, "failure")
  end
end
