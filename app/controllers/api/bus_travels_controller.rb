require 'http'

class Api::BusTravelsController < ApplicationController

  def index
    #returns information from next 7 days
    alert_id = params[:alert_id]
    alert = Alert.find_by(id: alert_id)
    if alert.last_update.nil? #this should only be the first time index is called, when viewed for the first time
      saved = alert.update_bus_alerts
      if saved == 'saved!'
        AlertJob.set(wait: 5.minutes).perform_later(alert_id) #immedatly starts alertjob loop, after first update
      else
        render json: {error: "error updating alert"}
      end
    end
    
    seven_days = get_next_seven_days()
    bus_travel_array = BusTravel.where(date: seven_days, alert_id: alert_id).map{|a| a.attributes}
    if bus_travel_array.empty?
      render json: {error: "couldn't retrieve bus_travels"}
    else
      render json: bus_travel_array
    end

  end

  def history
    #send historic price information
    #format: [[Y, M, D, H, M], price: 8000}, ...]
    alert_id = params[:alert_id]
    p_history = PriceHistory.where(alert_id: alert_id).order('created_at DESC').limit(50)
    result = []
    p_history.each do |p|
      h = p.attributes
      h['time'] = h['created_at'].strftime("%Y-%-m-%d-%H-%M").split("-").map{|s| s.to_i}
      h['time'][1] -= 1 #google usa meses desde 0 :/ !?
      result.push(h)
    end
    render json: result.reverse

  end

  private

    def get_next_seven_days()
      result = []
      d = Date.today
      (1..7).each do |n|
        result.push(d.strftime('%d-%m-%Y'))
        d += 1
      end
      return result
    end

end