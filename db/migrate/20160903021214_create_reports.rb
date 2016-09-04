class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :property_name, :limit => 255
      t.integer :monitoring_year, :limit => 2
      t.string :photographer_name, :limit => 255
      t.timestamps :null => false
    end
  end
end
