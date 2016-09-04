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
end
