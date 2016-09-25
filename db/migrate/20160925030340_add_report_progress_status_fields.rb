class AddReportProgressStatusFields < ActiveRecord::Migration
  def change
    add_column(:reports, :upload_progress, :string, :limit => 20)
    add_column(:reports, :pdf_progress, :string, :limit => 20)
  end
end
