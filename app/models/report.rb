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
  has_many :uploads
  has_many :photos, -> { order(:taken_at, :image, :id) }
  accepts_nested_attributes_for :photos, :allow_destroy => true

  # Virtual attributes
  attr_accessor :upload_uuids

  # Validations
  schema_validations
  validates :property_name, :presence => true
  validates :monitoring_year, :presence => true
  validates :photographer_name, :presence => true

  # Callbacks
  after_commit :handle_uploads

  def upload_uuids=(uuids)
    attribute_will_change!(:upload_uuids) if(@upload_uuids != uuids)
    @upload_uuids = uuids
  end

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
      self.update_column(:upload_progress, "pending")
      Delayed::Job.enqueue(ReportUploadsJob.new(self.id, self.upload_uuids.uniq))
    end
  end
end
