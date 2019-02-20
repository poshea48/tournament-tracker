module ApplicationHelper
  def normalize_date_title(date)
    Date.parse(date).strftime("%B %d %Y")
  end

  def normalize_date_table(date)
    Date.parse(date).strftime("%-m/%d/%Y")
  end
end
