class AddReportType < ActiveRecord::Migration
  def up
    execute("CREATE TYPE report_type AS ENUM ('baseline', 'monitoring')")
    add_column :reports, :type, :report_type, :null => false, :default => "monitoring"
  end

  def down
    remove_column :reports, :type
    execute("DROP TYPE report_type")
  end
end
