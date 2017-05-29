class AddReportExtraSignatures < ActiveRecord::Migration
  def change
    add_column :reports, :extra_signatures, :string, :limit => 255, :array => true
  end
end
