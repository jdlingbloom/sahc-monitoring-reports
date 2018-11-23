class ReportUploadsJob < ApplicationJob
  def perform(report_id, upload_uuids, current_user_id)
    Upload.transaction do
      begin
        report = Report.find(report_id)

        original_stamper = ActiveRecord::Userstamp.config.default_stamper_class.stamper
        ActiveRecord::Userstamp.config.default_stamper_class.stamper = current_user_id

        upload_uuids.each do |uuid|
          upload = Upload.find_by!(:uuid => uuid)
          upload.build_photos.each do |photo|
            photo.report_id = report.id
            photo.save!
          end
          upload.destroy
        end

        report.update_column(:upload_progress, nil)
      rescue => e
        if report
          report.update_column(:upload_progress, "failure")
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
