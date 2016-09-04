# == Schema Information
#
# Table name: uploads
#
#  id                :integer          not null, primary key
#  uuid              :string(36)       not null
#  file_id           :string(100)      not null
#  file_filename     :string(255)      not null
#  file_size         :integer          not null
#  file_content_type :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  creator_id        :integer
#  updater_id        :integer
#
# Indexes
#
#  index_uploads_on_uuid  (uuid) UNIQUE
#

class Upload < ActiveRecord::Base
  stampable

  attachment :file

  def build_photos
    photos = []

    case(self.file_content_type)
    when "application/vnd.google-earth.kmz"
      photos += build_photos_from_kmz
    when "image/jpeg"
      photos << build_photo_from_jpeg
    else
      raise "Unknown extension"
    end

    photos
  end

  private

  def build_photos_from_kmz
    photos = []

    coder = HTMLEntities.new
    Zip::File.open(self.file.download) do |zip_file|
      doc = REXML::Document.new(zip_file.glob("doc.kml").first.get_input_stream.read)
      zip_file.glob("files/*.jpg").each do |file|
        filename = File.basename(file.name)

        description = doc.elements.to_a("/kml/Document/Placemark/description").find do |description|
          description.text.include?(file.name)
        end

        description = REXML::Document.new("<root>#{description.text}</root>")
        subtitle = coder.decode(description.elements["//div[@id='com.miocool.mapplus.subtitle']"].text.strip)

        begin
          image = Tempfile.new(["", File.extname(filename)])
          image.binmode
          image.write(file.get_input_stream.read)
          image.rewind
          image.fsync

          photo = build_photo(image)
          photo.assign_attributes({
            :image_filename => filename,
            :original_image_filename => filename,
            :caption => subtitle,
          })

          photos << photo
        ensure
          image.close
        end
      end
    end

    photos
  end

  def build_photo_from_jpeg
    image = self.file.download
    photo = build_photo(image)
    photo.assign_attributes({
      :image_filename => self.file_filename,
      :image_content_type => self.file_content_type,
      :original_image_filename => self.file_filename,
      :original_image_content_type => self.file_content_type,
    })

    photo
  end

  def build_photo(image)
    image.rewind
    exif = EXIFR::JPEG.new(image)
    image.rewind

    # Auto-rotate the primary image used for display, but we'll also store the
    # raw version of the original image (mainly for downloads/archival
    # purposes).
    magick = MiniMagick::Image.open(image.path)
    magick.auto_orient

    photo = Photo.new({
      :image => File.open(magick.path, "rb"),
      :original_image => image,
      :taken_at => exif.date_time_original,
    })

    if(exif.gps)
      photo.assign_attributes({
        :latitude => exif.gps.latitude,
        :longitude => exif.gps.longitude,
        :altitude => exif.gps.altitude,
        :image_direction => exif.gps.image_direction,
      })
    end

    photo
  end
end
