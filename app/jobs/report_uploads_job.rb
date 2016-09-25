class ReportUploadsJob
  def initialize(report_id, upload_uuids)
    @report_id = report_id
    @upload_uuids = upload_uuids
  end

  def perform
    Upload.transaction do
      report = Report.find(@report_id)
      @upload_uuids.each do |uuid|
        upload = Upload.find_by!(:uuid => uuid)
        report.photos += upload.build_photos
        upload.destroy
      end

      report.update_column(:upload_progress, nil)
    end
  end

  def failure
    report = Report.find(@report_id)
    report.update_column(:upload_progress, "failure")
  end
end
