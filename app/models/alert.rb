class Alert < ApplicationRecord
  has_many :bus_travels, :dependent => :delete_all
  has_many :price_histories, :dependent => :delete_all
  validates_presence_of :departure_city_name
  validates_presence_of :destination_city_name
  #0: cualquiera, 1:premium, etc
  #enum bus_category: [:any, :premium, :salon_cama, :semi_cama, :pullman]
  after_save :after_save_check

  def after_save_check
    if saved_change_to_attribute?(:departure_city_name) || saved_change_to_attribute?(:destination_city_name)
      #delete everything?
      puts 'holi'
    end
  end

  def update_bus_alerts
    #considerando que se hacen 7 request que se pueden demorar hasta 10 segundos o más,
    #este método puede tomar un tiempo largo
    #updates bus_travels from alert for next 7 days, and price history as well. Doesn't return anything

    alert = self
    alert_id = alert.id
    #alert = Alert.find_by(id: alert_id) #(includes bus_travelas?)
    #alert = Alert.includes(:bus_travels).find_by(id: alert_id)
    if alert.nil?
      puts 'error: nil alert'
    end
    #next block is to avoid n+1 queries, loading all the necessary bustravels beforehand
    bus_travel_array = []
    unless alert["last_update"].nil?
      seven_days = get_next_seven_days()
      bus_travel_array = BusTravel.where(date: seven_days, alert_id: alert_id)
    end
    departure_city_id = alert[:departure_city_id]
    destination_city_id = alert[:destination_city_id]
    bus_category = alert[:bus_category]
    travels_result = []
    d = Date.today
    #updating bus travels for the next seven days.
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
            travels_result.push(get_lowest_price(bus_travel_data, bus_category, d.strftime('%d-%m-%Y'), 
            alert, bus_travel_array))
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
    #updating price history
    save_lowest_price(travels_result, alert_id)
    #updating datetime of last update. Also a mark that alert has been updated (isn't new)
    alert.last_update = DateTime.now
    if alert.save
      return 'saved!'
    else
      puts 'error saving alert after update'
    end

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

    def get_lowest_price(bus_travel_data, bus_category, date, alert, bus_travel_array)
      #returns the bus_travel with lowest price of alert with date and bus_category
      #also saves the bus_travel to database
      lowest_price = 999999.9 #aqui asumimos que habran tickets con precios más bajos que esto jaja

      bus_travel = bus_travel_array.select{|h| h["date"] == date}[0]
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
      return result
    end

end
