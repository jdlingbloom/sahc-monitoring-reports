class RemoveSoftDeletes < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        Photo.where("deleted_at IS NOT NULL").each do |photo|
          puts "Destroying photo #{photo.id}"
          photo.destroy
        end

        Report.where("deleted_at IS NOT NULL").each do |report|
          puts "Destroying report #{report.id}"
          report.destroy
        end
      end
    end

    remove_column :photos, :deleted_at, :datetime
    remove_column :photos, :deleter_id, :integer
    remove_column :reports, :deleted_at, :datetime
    remove_column :reports, :deleter_id, :integer
  end
end
