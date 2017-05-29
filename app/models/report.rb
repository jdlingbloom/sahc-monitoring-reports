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
#  deleted_at        :datetime
#  creator_id        :integer
#  updater_id        :integer
#  deleter_id        :integer
#  upload_progress   :string(20)
#  pdf_progress      :string(20)
#
# Indexes
#
#  index_reports_on_deleted_at  (deleted_at)
#

class Report < ActiveRecord::Base
  acts_as_paranoid
  stampable

  # Associations
  has_many :photos, -> { order(:taken_at, :image, :id) }, :dependent => :destroy
  accepts_nested_attributes_for :photos, :allow_destroy => true

  # Virtual attributes
  attr_accessor :upload_uuids

  # Validations
  schema_validations
  validates :property_name, :presence => true
  validates :monitoring_year, :presence => true
  validates :photographer_name, :presence => true
  validate :validate_photos_presence

  # Callbacks
  after_commit :handle_uploads

  def upload_uuids=(uuids)
    attribute_will_change!(:upload_uuids) if(@upload_uuids != uuids)
    @upload_uuids = uuids
  end

  def display_name
    @display_name ||= "#{self.monitoring_year} #{self.property_name}"
  end

  def photo_dates
    dates = {}
    self.photos.each_with_index do |photo, index|
      if(photo.taken_at)
        photo_num = index + 1
        date = photo.taken_at.to_date
        dates[date] ||= []
        dates[date] << photo_num
      end
    end

    dates.each do |date, photo_nums|
      dates[date] = photo_nums.first..photo_nums.last
    end

    dates
  end

  private

  def validate_photos_presence
    if(self.photos.blank? && self.upload_uuids.blank?)
      self.errors.add(:base, "Must upload one or more photos.")
    end
  end

  def handle_uploads
    if(self.upload_uuids.present?)
      self.update_column(:upload_progress, "pending")
      Delayed::Job.enqueue(ReportUploadsJob.new(self.id, self.upload_uuids.uniq))
    end
  end
end
