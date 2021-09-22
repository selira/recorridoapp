require 'http'

class Api::AlertsController < ApplicationController

  # GET /alerts or /alerts.json
  def index
    @alerts = Alert.all.order('id DESC')
    render json: @alerts
  end

  def show
    @alert = Alert.find(params[:id])
    h = @alert.attributes
    h['minutes'] = nil
    unless @alert.last_update.nil?
      minutes = DateTime.now - h["last_update"].to_datetime
      h['minutes'] = (minutes*24*60).to_i
    end
    render json: h
  end

  def cities
    @cities = HTTP.basic_auth(:user => "recorrido", :pass => "recorrido")
      .headers(:accept => "application/json")
      .get("https://demo.recorrido.cl/api/v2/es/cities.json?country=chile").body.to_s
    render json: @cities
  end

  # POST /alerts or /alerts.json
  def create
    @alert = Alert.new(alert_params)
    if @alert.save
      render json: { status: :ok, message: 'Success' }
    else
      render json: @alert.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /alerts/1 or /alerts/1.json
  def update
    @alert = Alert.find(params[:id])
    if @alert.update(alert_params)
      render json: { status: :ok, message: 'Success' }
    else
      render json: { json: @alert.errors, status: :unprocessable_entity }
    end
  end

  # DELETE /alerts/1 or /alerts/1.json
  def destroy
    @alert = Alert.find(params[:id])
    if @alert.destroy
      render json: { json: 'Alert was successfully deleted.'}
    else
      render json: { json: @alert.errors, status: :unprocessable_entity }
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def alert_params
      params.require(:alert).permit(:name, :departure_city_id, :departure_city_name, :departure_city_url_name,
        :destination_city_id, :destination_city_name, :destination_city_url_name, :bus_category, :price)
    end
end
