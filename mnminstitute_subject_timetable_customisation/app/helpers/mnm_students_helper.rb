module MnmStudentsHelper
  def validation_errors(msg)
    if msg.class.to_s == "Array"
      msg = msg.join(",")
    else
      !msg.blank? ? msg :""
  
    end
  end

  def show_header_icon
    "<div class='header-icon report-icon'></div>".html_safe
  end

end
