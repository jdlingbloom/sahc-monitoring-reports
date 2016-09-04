# == Schema Information
#
# Table name: photos
#
#  id                 :integer          not null, primary key
#  report_id          :integer          not null
#  caption            :text
#  image_id           :string(100)      not null
#  image_filename     :string(255)      not null
#  image_size         :integer          not null
#  image_content_type :string(255)      not null
#  taken_at           :datetime
#  latitude           :decimal(10, 7)
#  longitude          :decimal(10, 7)
#  altitude           :decimal(12, 7)
#  image_direction    :decimal(10, 7)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
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

  attachment :image

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
      @altitude_feet ||= (self.altitude * 3.28084).to_i
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
end
