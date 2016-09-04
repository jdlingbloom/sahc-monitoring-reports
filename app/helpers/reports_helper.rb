module ReportsHelper
  def monitoring_year_options(report)
    todays_year = Date.today.year
    min_year = [report.monitoring_year, todays_year].compact.min - 1
    max_year = [report.monitoring_year, todays_year].compact.max + 1
    min_year..max_year
  end
end
