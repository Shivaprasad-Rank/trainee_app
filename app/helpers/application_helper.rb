module ApplicationHelper
	def validation_errors(msg)
    if msg.class.to_s == "Array"
      msg = msg.join(",")
    else
      !msg.blank? ? msg :""

    end
  end
end
