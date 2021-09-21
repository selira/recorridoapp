require 'http'

class Api::BusTravelsController < ApplicationController

  def update(alert_id = -1)
    #considerando que se hacen 7 request que se pueden demorar hasta 10 segundos o más,
    #este método puede tomar un tiempo largo
    #updates bus_travels from alert for next 7 days, and price history as well. Doesn't return anything

    if alert_id == -1
      alert_id = params[:alert_id]
    end

    #alert = Alert.find_by(id: alert_id) #(includes bus_travelas?)
    alert = Alert.includes(:bus_travels).find_by(id: alert_id)
    if alert.nil?
      render json: {error: 'alert not found'}
    end
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
            travels_result.push(get_lowest_price(bus_travel_data, bus_category, d.strftime('%d-%m-%Y'), alert))
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
    # puts 'putting travels result in end of update method'
    # puts travels_result
    save_lowest_price(travels_result, alert_id)

    #TODO: COMMENT THIS LINE AFTER FINISHING
    render json: travels_result
    #alternative:
    #index()

  end

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
    # d = Date.today
    # bus_travels = []
    # (1..7).each do |n|
    #   date_search = d.strftime('%d-%m-%Y')
    #   bt = alert.bus_travels.find_by(date: date_search)
    #   unless bt.nil?
    #     bus_travels.push(bt.attributes)
    #   end
    #   d += 1
    # end
    if bus_travel_array.empty?
      render json: {error: "couldn't retrieve bus_travels"}
    else
      render json: bus_travel_array
    end

  end

  def history
    #send historic price information
    #format: [{date: 01-01-2050, price: 8000}, ...]
    alert_id = params[:alert_id]
    alert = Alert.includes(:price_histories).find_by(id: alert_id)
    if alert.nil?
      render json: {error: 'no alert'}
    end
    p_history = alert.price_histories.order('created_at DESC').limit(50)
    result = []
    p_history.each do |p|
      a = p.attributes
      a['time'] = a['created_at'].strftime("%Y-%-m-%d-%H-%M").split("-").map{|s| s.to_i}
      a['time'][1] -= 1 #google usa meses desde 0 :/ !?
      result.push(a)
    end
    render json: result.reverse

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

    def get_lowest_price(bus_travel_data, bus_category, date, alert)
      #returns the bus_travel with lowest price of alert with date and bus_category
      #also saves the bus_travel to database
      lowest_price = 999999.9 #aqui asumimos que habran tickets con precios más bajos que esto jaja
      bus_travel = alert.bus_travels.find_by(date: date)
      bus_copy = bus_travel
      new_bus_travel_found = false
      if bus_travel.nil?
        bus_travel = {}
      else
        lowest_price = bus_travel['price']
        bus_travel = bus_travel.attributes
      end
      bus_travel_data.each do |data_point|
        if lowest_price > data_point['price'] && (bus_category == 0 || bus_category == data_point['seat_klass_stars'] )
          lowest_price = data_point['price']
          bus_travel = {date: date, time: data_point['departure_time'].to_datetime.strftime("%H:%M"),
              bus_category: data_point['seat_klass_stars'], price: data_point['price'],
              company: data_point['bus_operator_name']}
          new_bus_travel_found = true
        end
      end
      unless bus_travel.empty?  || new_bus_travel_found == false 
        #saved only if there is data to show and found new bus_travel
        bt = BusTravel.new(bus_travel)
        bt.alert_id = alert.id
        unless bus_copy.nil? #must delete original bus_travel before save to update, only one bus_travel per date and alert
          bus_copy.delete
        end
        unless bt.save
          puts 'bus travel not saved to database'
        end
      end
      return bus_travel
    end

    def save_lowest_price(travels_result, alert_id)
      lowest_price = 999999.9
      travels_result.each do |tr|
        unless tr.empty?
          price = tr[:price] || tr['price'] #no entendí este bug sinceramente (tiraba nil con uno y otro, no ambos al mismo tiempo)
          if lowest_price > price
            lowest_price = price
          end
        end
      end
      unless lowest_price == 999999.9
        pr = PriceHistory.new()
        pr.alert_id = alert_id
        pr.price = lowest_price
        unless pr.save
          puts 'error saving price history'
        end
      end
    end

    def get_next_seven_days()
      result = []
      d = Date.today
      (1..7).each do |n|
        result.push(d.strftime('%d-%m-%Y'))
        d += 1
      end
    end

end