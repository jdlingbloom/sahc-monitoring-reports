# == Schema Information
#
# Table name: photos
#
#  id                 :integer          not null, primary key
#  report_id          :integer          not null
#  caption            :text
#  image              :string(255)      not null
#  image_size         :integer          not null
#  image_content_type :string(255)      not null
#  taken_at           :datetime
#  latitude           :decimal(10, 7)
#  longitude          :decimal(10, 7)
#  altitude           :decimal(12, 7)
#  image_direction    :decimal(10, 7)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  deleted_at         :datetime
#  creator_id         :integer
#  updater_id         :integer
#  deleter_id         :integer
#
# Indexes
#
#  index_photos_on_deleted_at  (deleted_at)
#

class Photo < ActiveRecord::Base
  # https://github.com/DaAwesomeP/arduino-cardinal/wiki/Types/fb25844994f1fb2b0eb915c73766827459388cfb#type-2
  COMPASS_HEADINGS = [
    "N",
    "NNE",
    "NE",
    "ENE",
    "E",
    "ESE",
    "SE",
    "SSE",
    "S",
    "SSW",
    "SW",
    "WSW",
    "W",
    "WNW",
    "NW",
    "NNW",
  ]
  COMPASS_HEADING_SIZE = 360.0 / COMPASS_HEADINGS.length
  COMPASS_HEADING_BUFFER = COMPASS_HEADING_SIZE / 2.0
  COMPASS_HEADING_NORTH_START = 360.0 - COMPASS_HEADING_BUFFER

  acts_as_paranoid
  stampable

  # Associations
  belongs_to :report

  # Virtual attributes
  attr_accessor :upload_uuid

  # File attachments
  mount_uploader :image, PhotoImageUploader

  # Callbacks
  before_validation :set_upload_metadata
  after_commit :handle_upload_replacement

  # Exclude file uploads from automatic schema validations, since length
  # validations validate the file size (not filename length) for file uploads.
  schema_validations :except => [:image]

  def upload_uuid=(uuid)
    attribute_will_change!(:upload_uuid) if(@upload_uuid != uuid)
    @upload_uuid = uuid
  end

  def latitude_rounded
    if(self.latitude)
      @latitude_rounded ||= self.latitude.round(5)
    end
  end

  def longitude_rounded
    if(self.longitude)
      @longitude_rounded ||= self.longitude.round(5)
    end
  end

  def altitude_feet
    if(self.altitude)
      @altitude_feet ||= (self.altitude * 3.28084).round
    end
  end

  def image_direction_heading
    unless @image_direction_heading
      if(self.image_direction)
        # Anything greater than 348.75 degrees should get looped back to the
        # first element to be considered "N".
        degrees = self.image_direction % COMPASS_HEADING_NORTH_START
        heading_index = ((degrees + COMPASS_HEADING_BUFFER) / COMPASS_HEADING_SIZE).floor
        @image_direction_heading = COMPASS_HEADINGS[heading_index]
      end
    end

    @image_direction_heading
  end

  private

  def handle_upload_replacement
    if(self.upload_uuid.present?)
      self.report.update_column(:upload_progress, "pending")
      Delayed::Job.enqueue(PhotoUploadReplacementJob.new(self.id, self.upload_uuid))
    end
  end

  def set_upload_metadata
    if(self.image.present? && self.image_cache.present?)
      self.image_content_type = self.image.content_type
      self.image_size = self.image.size
    end
  end
end
