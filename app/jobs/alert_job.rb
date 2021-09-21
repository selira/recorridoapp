require 'json'
class AlertJob < ApplicationJob
  queue_as :default

  def perform(alert_id)
    # Do something later
    alert = Alert.find_by(id: alert_id)
    unless alert.nil?
      AlertJob.set(wait: 5.minutes).perform_later(alert_id)
      alert.update_bus_alerts
    end
  end
end
