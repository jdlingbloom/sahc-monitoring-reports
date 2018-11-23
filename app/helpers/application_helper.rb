module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type.to_s
    when "success"
      "alert-success"
    when "error"
      "alert-danger"
    when "alert"
      "alert-warning"
    when "notice"
      "alert-info"
    else
      "alert-#{flash_type}"
    end
  end

  def database_rows
    @database_rows ||= ActiveRecord::Base.connection.select_value("SELECT SUM(n_live_tup) FROM pg_stat_user_tables").to_i
  end

  def database_rows_limit
    10000
  end

  def database_rows_percent
    @database_rows_percent ||= ((database_rows / database_rows_limit.to_f) * 100).round
  end

  def database_size
    @database_size ||= ActiveRecord::Base.connection.select_value("SELECT pg_table_size('pg_largeobject')").to_i
  end
end
