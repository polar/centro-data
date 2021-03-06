require 'open-uri'
require "net/http"

class LocationJob < Struct.new(:queue, :period, :master_id)
  include LocationBoxing

  attr_accessor :http_client, :session_cookies
  attr_accessor :master, :api

  def logged_in?
    ! session_cookes.empty?
  end

  def busme_get(uri)
    headers = {
        "Cookie" => session_cookies.to_s
    }
    resp = http_client.get(URI(uri).path, headers)
    self.session_cookies = CGI::Cookie.parse(resp.header["set-cookie"]) if resp.header["set-cookie"]
    return resp.body
  end

  def busme_post(uri, data)
    headers = {
        "Cookie" => session_cookies.map{|k,v| v.to_s}.join("; ")
    }
    resp = http_client.post(URI(uri).path, data, headers)
    self.session_cookies = CGI::Cookie.parse(resp.header["set-cookie"]) if resp.header["set-cookie"]
    return resp.body
  end

  def enqueue(job)
    puts "Equeued Job #{queue} #{period} #{Master.find(master_id).slug}."
  end

  def perform
    doit
  ensure
    Delayed::Job.enqueue(self, :queue => queue, :run_at => Time.now + period.seconds)
  end

  def doit
    self.master = Master.find(master_id)
    self.api = master.api

    auth_token = "DFsBxSuxtR2xyasFpwJM" # polar@syr.edu busme.us
    #auth_token = "kmZ95RYyJpahMfNTZsVw" # polar@syr.edu busme-stage.adiron.com
    auth(auth_token)
    buses = []
    route_codes = master.journeys.map {|x| x.route_code}.uniq
    for route_code in route_codes do
      buses += update_locations(route_code)
    end

    for bus in buses do
      figure_locations(bus)
    end

  rescue Exception => boom
    puts "Error #{boom}"
    p boom.backtrace
  end

  def update_locations(route_code)
    resp  = Hash.from_xml open("http://bus-time.centro.org/bustime/map/getBusesForRoute.jsp?route=#{route_code}&nsd=true&key=0.30387086560949683")
    # puts "got resp #{resp.inspect}"
    buses = resp["buses"]
    centro_buses = []
    if !buses["bus"].nil?
      if buses["bus"].is_a? Array
        puts "Got #{buses["bus"].count} bus locations for the #{route_code}."
        centro_buses = buses["bus"].map { |x| CentroBus.make(buses["time"], x) }
      elsif buses["bus"].is_a? Hash
        puts "Got 1 bus locations for the #{route_code}."
        centro_buses = [CentroBus.make(buses["time"], buses["bus"])]
      end
    end
    return centro_buses
  end

  def centro_direction_match?(centro_bus, journey)
    case journey.route_code
      when "45"
        centro_bus.dd == "FROM CAMPUS" && journey.dir == "ToCampus" ||
            centro_bus.dd == "TO CAMPUS" && journey.dir == "Destiny"
      when "443"
        centro_bus.dd == "FROM WAREHOUSE" && journey.dir == "SouthCampus" ||
            centro_bus.dd == "TO WAREHOUSE" && journey.dir == "Warehouse"
      when "144"
        centro_bus.dd == "TO CAMPUS" && journey.dir == "MainCampus" ||
            centro_bus.dd == "FROM CAMPUS" && journey.dir == "SouthCampus"
      when "244"
        centro_bus.dd == "TO CAMPUS" && journey.dir == "MainCampus" ||
            centro_bus.dd == "FROM CAMPUS" && journey.dir == "SouthCampus"
      when "344"
        centro_bus.dd == "TO CAMPUS" && journey.dir == "MainCampus" ||
            centro_bus.dd == "FROM CAMPUS" && journey.dir == "SouthCampus"
      when "44"
        centro_bus.dd == "TO CAMPUS" && journey.dir == "MainCampus" ||
            centro_bus.dd == "FROM CAMPUS" && journey.dir == "SouthCampus"
      else
        false
    end
  end

  # Negative is early.
  def time_diff(time_now, journey, ti_dist)
    journey.start_time + ti_dist.minutes - time_now
  end

  def getResults(time_now, journey, centro_bus)
    average_speed = journey.average_speed
    results = getPossible(journey.pattern.coords, [centro_bus.lon, centro_bus.lat], 60, average_speed)
    if results && results.size > 0
      results.each do |r|
        r[:p_dist] = 100*r[:distance]/journey.path_distance
        r[:p_dist_diff] = journey.p_dist(time_now) - r[:p_dist]
        r[:sched_time] = journey.start_time + r[:ti_dist].minutes
        r[:time_diff]  = time_diff(time_now, journey, r[:ti_dist])
        r[:time_start] = journey.start_offset
      end
      results.sort! {|x,y| x[:time_diff].abs <=> y[:time_diff].abs}
    end
    results
  end

  def resultApplies?(time_now, result)
    journey = result[:journey]
    if time_now > journey.start_time
      for r in result[:res] do
        time_diff = r[:time_diff]
        if -5.minutes < time_diff && -5.0 < r[:p_dist_diff]
          return result
        end
      end
    end
    return nil
  end

  def figure_locations(centro_bus)
    time_now = Time.zone.now
    if true || centro_bus.journey.nil?
      if !centro_bus.journey.nil?
        puts "Centro  Bus #{centro_bus.centroid} #{centro_bus.rt} is assigned #{centro_bus.journey.start_time.strftime("%H:%M")}"
      end
      if true
        puts "Figure Locations Centro Bus #{centro_bus.centroid}...."
        centro_bus_results = []
        js = Journey.where(:master_id => master.id, :route_code => centro_bus.rt).all
        journeys = js.select {|x| centro_direction_match?(centro_bus, x)}
        puts "From #{js.size} for #{centro_bus.rt} we are looking at  journeys in which #{journeys.size} match direction...."
        journeys.each do |journey|
          if centro_direction_match?(centro_bus, journey)
            results = getResults(time_now, journey, centro_bus)
            if results && results.size > 0
              centro_bus_results << {:journey => journey, :res => results}
            end
            puts "ActiveJourney.find_by_persistentid(:active, '#{journey.persistentid}').vehicle_journey.journey_pattern.get_possible(#{[centro_bus.lon, centro_bus.lat]}, 60)"
            puts "got #{results.size} results #{results}"
          end
        end
      end
      if centro_bus_results.size == 1
        puts "Found one journey for CentroBus #{centro_bus.centroid}"
        if resultApplies?(time_now, centro_bus_results.first)
          if centro_bus.journey && centro_bus.journey.id != centro_bus_results.first[:journey].id
            puts "Changing journey for CentroBus from #{centro_bus.journey.start_time.strftime('%H:%M')} to #{centro_bus_results.first[:journey].start_time.strftime('%H:%M')}"
            centro_bus.journey.centro_bus = nil
            centro_bus.journey.save
          end
          centro_bus.journey = centro_bus_results.first[:journey]
          centro_bus.journey_results = centro_bus_results.map {|x| x[:journey] = x[:journey].id; x}
          centro_bus.save
          centro_bus.journey.centro_bus = centro_bus
          centro_bus.journey.save
        else
          puts "Single answer does not apply. Ignoring."
        end
      else
        puts "Have #{centro_bus.journeys.size} journeys for CentroBus #{centro_bus.centroid}"
        centro_bus.message = "Have #{centro_bus.journeys.size} journeys. "
        # Sort by closest to time now. Might not be totally correct.
        centro_bus_results.sort! {|x,y| x[:res][0][:time_diff] <=> y[:res][0][:time_diff] }
        for r in centro_bus_results do
          if ans = resultApplies?(time_now, r)
            if centro_bus.journey && centro_bus.journey.id != ans[:journey].id
              puts "Changing journey for CentroBus from #{centro_bus.journey.start_time.strftime('%H:%M')} to #{r[:journey].start_time.strftime('%H:%M')}"
              centro_bus.journey.centro_bus = nil
              centro_bus.journey.save
            end
            ans[:selected] = true
            centro_bus.journey =  r[:journey]
            centro_bus.journey_results = centro_bus_results.map {|x| x[:journey] = x[:journey].id; x}
            centro_bus.save
            centro_bus.journey.centro_bus = centro_bus
            centro_bus.journey.save
            break
          end
        end
      end
    end

    if centro_bus.journey
      report_journey_location(centro_bus)
    else
      if centro_bus_results
        centro_bus.message = ""
        for r in centro_bus_results do
          journey = r[:journey]
          time = journey.start_time.strftime("%H:%M %Z")
          dist = "%8.2f%" % r[:res][0][:p_dist]
          diff = "%8.2f" % (r[:res][0][:time_diff]/60)
          msg = "[#{time} #{dist} #{diff}] "
          centro_bus.message += msg
        end
        centro_bus.journey_results = centro_bus_results.map {|x| x[:journey] = x[:journey].id; x}
      end

      puts "Did not report on Centro Bus #{centro_bus.centroid} #{centro_bus.message}"
      centro_bus.save
    end
  end

  def auth(auth_token)
    uri = URI(api.auth)
    self.http_client = Net::HTTP.new(uri.host, uri.port)
    http_client.use_ssl = uri.port == 443
    data = "access_token=#{auth_token}&app_version=1.0.0"
    headers = {}
    resp = http_client.post(uri.path, data, headers)
    self.session_cookies = CGI::Cookie.parse(resp.header["set-cookie"])
    res = Hash.from_xml resp.body
    if res && res["login"] && res["login"]["status"] == "OK"
      return true
    else
      return false
    end
    p session_cookies
  end

  def centro_dir_to_busme_dir(dir)
    case dir
      when "N"
        0
      when "NNE"
        22.5
      when "NE"
        45
      when "ENE"
        67.5
      when "E"
        90
      when "ESE"
        112.5
      when "SE"
        135
      when "SSE"
        157.5
      when "S"
        180
      when 'SSW'
        202.5
      when "SW"
        225
      when "WSW"
        247.5
      when "W"
        270
      when "WNW"
        292.5
      when "NW"
        315
      when "NNW"
        337.5
      else
        0.0
    end
  end

  def report_journey_location(centro_bus)
    puts "Reporting location for CentroBus #{centro_bus.centroid} on #{centro_bus.journey.route_code}"
    url = centro_bus.journey.api.post_journey_location
    dir = centro_dir_to_busme_dir(centro_bus.dn)
    speed = 60
    data = "id=#{centro_bus.journey.persistentid}&dir=#{dir}&speed=#{speed}&lon=#{centro_bus.lon}&lat=#{centro_bus.lat}&reported_time=#{Time.now.to_i*1000}&driver=1&vid=#{centro_bus.centroid}"

    puts url
    puts data
    res = Hash.from_xml  busme_post(url, data)
    return res
  end
end