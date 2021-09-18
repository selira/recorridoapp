require 'http'

class Api::BusTravelsController < ApplicationController

  def getBusTravels
    bus_travel = "bus_travel%5Bdeparture_city_id%5D=9333&bus_travel%5Bdestination_city_id%5D=9360&bus_travel%5Bdeparture_date%5D=01-10-2021"
    response = HTTP.basic_auth(:user => "recorrido", :pass => "recorrido").headers(:accept => "application/json", "Content-Type" => "application/x-www-form-urlencoded").post("https://demo.recorrido.cl/api/v2/es/bus_travels.json", :body => bus_travel).body.to_s
    render json: @alerts
  end

end