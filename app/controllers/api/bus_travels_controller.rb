require 'http'

class Api::BusTravelsController < ApplicationController

  def update
    #considerando que se hacen 7 request que se pueden demorar hasta 10 segundos o más,
    # este  método puede tomar un tiempo largo

    alert_id = params[:alert_id]
    alert = Alert.find(alert_id)
    departure_city_id = alert[:departure_city_id]
    destination_city_id = alert[:destination_city_id]
    bus_category = alert[:bus_category]
    travels_result = []
    d = Date.today
    (1..7).each do |n|
      #initial request
      response = bus_travels_request(departure_city_id, destination_city_id, d)
      if response.status.success? #if not succesful doesn't add element to result array
        search_data = response.parse
        search_url = search_data['search_progres_url']
        search_id = search_data['search_id']
        data_url = "https://demo.recorrido.cl/api/v2/es/bus_travels/"+search_data['id'].to_s+"/search_results.json"

        if status_polling_request(search_url) #if not succesful doesn't add element to result array
          res2 = data_fetch_request(search_id)
          if res2.status.success?
            bus_travel_data = res2.parse['outbound']['search_results']
            travels_result.push(get_lowest_price(bus_travel_data, bus_category, d.strftime('%d-%m-%Y')))
          else
            puts res2
          end
        else
          puts 'polling search_url failed'
        end
      else
        puts response
      end
      d += 1
    end
    render json: travels_result
  end

  private
    
    def bus_travels_request(departure_city_id, destination_city_id, date)
      #returns hash with api response (search_progres_url, etc)
      bus_travel = "bus_travel%5Bdeparture_city_id%5D=" + departure_city_id.to_s + "&bus_travel%5Bdestination_city_id%5D=" +
      destination_city_id.to_s + "&bus_travel%5Bdeparture_date%5D=" + date.strftime('%d-%m-%Y')
      return HTTP.basic_auth(:user => "recorrido", :pass => "recorrido").
        headers(:accept => "application/json", "Content-Type" => "application/x-www-form-urlencoded").
        post("https://demo.recorrido.cl/api/v2/es/bus_travels.json", :body => bus_travel)
    end
    
    def status_polling_request(search_url)
      #hace 20 request en 10 segundos, si no tira false y no se devuelve la información.
      (1..20).each do |n|
        r = HTTP.basic_auth(:user => "recorrido", :pass => "recorrido")
          .headers(:accept => "application/json")
          .get(search_url).parse
        if r['progress_status'] == "complete"
          return true
        end
        sleep 0.5
      end
      return false
    end
  
    def data_fetch_request(search_id)
      #returns array of result objects (each ticket)
      data_url = "https://demo.recorrido.cl/api/v2/es/bus_travels/"+search_id.to_s+"/search_results.json"
      return HTTP.basic_auth(:user => "recorrido", :pass => "recorrido")
          .headers(:accept => "application/json")
          .get(data_url)
    end

    def get_lowest_price(bus_travel_data, bus_category, date)
      lowest_price = 999999.9 #aqui asumimos que habran tickets con precios más bajos que esto jaja
      bus_travel = {}
      bus_travel_data.each do |data_point|
        if lowest_price > data_point['price'] && (bus_category == 0 || bus_category == data_point['seat_klass_stars'] )
          lowest_price = data_point['price']
          bus_travel = {date: date, time: data_point['departure_time'].to_datetime.strftime("%H:%M"),
              bus_category: data_point['seat_klass_stars'], price: data_point['price'],
              company: data_point['bus_operator_name']}
        end
      end
      return bus_travel
    end

end