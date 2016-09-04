# == Schema Information
#
# Table name: reports
#
#  id                :integer          not null, primary key
#  property_name     :string(255)
#  monitoring_year   :integer
#  photographer_name :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Report < ActiveRecord::Base
  # Associations
  has_many :uploads
  has_many :photos, -> { order(:taken_at, :image_filename, :id) }
  accepts_nested_attributes_for :photos, :allow_destroy => true

  # Virtual Attributes
  attr_accessor :upload_uuids

  # Validations
  validates :property_name, :presence => true
  validates :monitoring_year, :presence => true
  validates :photographer_name, :presence => true

  # Callbacks
  before_validation :handle_uploads

  def display_name
    @display_name ||= "#{self.monitoring_year} #{self.property_name}"
  end

  def photos_date
    frequency = {}
    dates = self.photos.map { |p| p.taken_at.to_date if(p.taken_at) }.compact
    dates.each do |date|
      frequency[date] ||= 0
      frequency[date] += 1
    end

    # Find the most frequently used date among all the photos. In the case of
    # tie, pick the first date.
    most_frequent = dates.max_by { |date| [frequency[date], date.to_time.to_i * -1] }

    most_frequent
  end

  private

  def handle_uploads
    if(self.upload_uuids.present?)
      self.upload_uuids.each do |uuid|
        upload = Upload.find_by!(:uuid => uuid)
        self.photos += upload.build_photos
        upload.destroy
      end
    end
  end
end
