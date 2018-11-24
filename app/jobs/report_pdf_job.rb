class ReportPdfJob < ApplicationJob
  def perform(report_id)
    Report.transaction do
      begin
        report = Report.find(report_id)

        report.generate_pdf
        Report.without_stamps do
          report.save!(:touch => false)
        end

        report.update_column(:pdf_progress, nil)
      rescue => e
        if report
          report.update_column(:pdf_progress, "failure")
        end

        raise e
      end
    end
  end
end
