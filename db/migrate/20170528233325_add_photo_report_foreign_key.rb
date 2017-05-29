class AddPhotoReportForeignKey < ActiveRecord::Migration
  def change
    add_foreign_key :photos, :reports
  end
end
