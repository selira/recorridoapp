require 'json'
class AlertJob < ApplicationJob
  queue_as :default

  def perform(alert_id)
    # Do something later
    alert = Alert.find_by(id: alert_id)
    # para que no haya workers extra cuando se borra o edita una alerta:
    unless alert.nil? # || (DateTime.now - 4.minutes < alert.last_update) si agrego esto quizás es demasiada complejidad
      AlertJob.set(wait: 5.minutes).perform_later(alert_id)
      alert.update_bus_alerts
    end
  end
end
