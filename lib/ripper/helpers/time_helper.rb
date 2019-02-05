module TimeHelper
  def human_seconds(total_seconds)
    hours = (total_seconds / 3600).floor
    minutes = ((total_seconds / 60) - (hours * 60)).floor
    seconds = total_seconds - ((hours * 3600) + (minutes * 60))
    format('%02d hours, %02d minutes, %02d seconds', hours, minutes, seconds)
  end
end
