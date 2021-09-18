require 'http'

class Api::BusTravelsController < ApplicationController

  # GET /alerts or /alerts.json
  def index
    @alerts = Alert.all.order('id DESC')
    render json: @alerts
  end

end