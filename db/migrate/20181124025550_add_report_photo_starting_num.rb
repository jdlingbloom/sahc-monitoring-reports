class AddReportPhotoStartingNum < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :photo_starting_num, :integer, :null => false, :default => 1
  end
end
