require 'open-uri'

class RefreshJob < Struct.new(:queue, :period, :api_id, :op)

  def enqueue(job)
    puts "Equeued Job #{queue} #{period} for #{Api.find(api_id).slug}."
  end

  def perform
    doit
  rescue Exception => boom
    puts "Error #{boom}"
    p boom.backtrace
  ensure
    Delayed::Job.enqueue(self, :queue => queue, :run_at => Time.now + period.seconds) if period > 0
  end

  def doit
    api = Api.find(api_id)
    case op
      when "reset"
        reset(api)
      when "refresh"
        refresh(api)
      else
    end
  rescue Exception => boom
    puts "Error #{boom}"
    p boom.backtrace
    raise boom
  end

  def refresh_masters(url)
    Master.destroy_all
    resp = Hash.from_xml open(url)
    for m in resp["masters"]["master"] do
      m["bounds"] = m["bounds"].split(",").map {|x| x.to_f}
      master = Master.new()
      master.from_hash(m)
      master.save
    end
  end

  def refresh_master_by_slug(slug)
    master = Master.find_by_slug(slug)
    if master
      refresh_master(master)
    else
      raise "Master Not Found"
    end
  end

  def refresh_master(master)
    api = master.api
    if api
      refresh(api)
    else
      load_api(master)
      refresh(master.api)
    end
  end

  # PATCH/PUT /apis/1
  def load_api(master)
    api = master.api
    if !api.nil?
      api.destroy
    end
    api = Api.new(:master => master)
    resp = Hash.from_xml open(master.api_url)
    api.from_hash(resp["API"])
    api.master = master
    api.save
    master.api = api
    master.save
    return api
  end

  def reset(api)
    Delayed::Job.where(:queue => "refresh").each do |x|
      if x.payload_object.api_id == api.id
        x.destroy
      end
    end
    Delayed::Job.where(:queue => "locate").each do |x|
      if x.payload_object.api_id == api.id
        x.destroy
      end
    end
    Route.where(:master_id => api.master.id).destroy_all
    Journey.where(:master_id => api.master.id).destroy_all
    Pattern.where(:master_id => api.master.id).destroy_all
    Delayed::Job.enqueue(RefreshJob.new(:refresh, 60, api.id, "refresh"), :queue => "refresh")
    Delayed::Job.enqueue(LocationJob.new(:locate, 10, api.master.id), :queue => "locate")
  end

  def refresh(api)
    resp = Hash.from_xml open(api.get_route_journey_ids1)
    js = resp["Response"]["J"]
    journeys = get_journeys(api.master, js)

    rs  = resp["Response"]["R"]
    routes = get_routes(api.master, rs)
    update_routes(routes)
    update_journeys(journeys)
  end

  def get_routes(master, rs)
    routes = []
    if rs
      rs = [rs] if !rs.is_a? Array
      for r in rs do
        name, id, type, version = r.split(",")
        r                       = Route.find_by_persistentid(id)
        if (r.nil? || r && r.version < version.to_i)
          r.destroy if r
          r = Route.new(
              :name         => name,
              :persistentid => id,
              :version      => version.to_i,
              :master       => master,
              :api          => master.api
          )
          r.save
        end
        routes << r
      end
    end
    return routes
  end

  def get_journeys(master, js)
    journeys = []
    if js
      js = [js] if !js.is_a? Array
      for r in js do
        name, id, type, version = r.split(",")
        j                       = Journey.find_by_persistentid(id)
        if (j.nil? || j && j.version < version.to_i)
          j.destroy if j
          j = Journey.new(
              :name         => name,
              :persistentid => id,
              :version      => version.to_i,
              :master       => master,
              :api          => master.api
          )
          j.save
        end
        journeys << j
      end
    end
    return journeys
  end

  def update_journeys(journeys)
    ids = []
    for x in journeys do
      update_journey(x) if x.needs_update?
      ids << x.id
    end
    # Going to get rid of journeys that are not in the list
    for x in Journey.all do
      if ! ids.include?(x.id)
        if x.centro_bus
          x.centro_bus.destroy
        end
        x.destroy
      end
    end
  end

  def update_routes(routes)
    for r in routes do
      update_route(r) if r.needs_update?
    end
  end

  def update_journey(journey)
    api = journey.api
    url = api.get_route_definition
    url = "#{url}?id=#{journey.persistentid}&type=V"
    resp = Hash.from_xml open(url)
    if resp["Route"]
      journey.from_hash(resp["Route"])
      if journey.patternid
        update_journey_pattern(api, journey)
      end
      journey.route = Route.find_by_master_id_and_route_code(journey.master.id, journey.route_code)
      journey.save
    end
    return journey
  end

  def update_journey_pattern(api, journey)
    url  = api.get_route_definition
    url  = "#{url}?id=#{journey.patternid}&type=P"
    resp = Hash.from_xml open(url)
    if resp["Route"]
      pattern = Pattern.find_by_persistentid_and_master_id(resp["Route"]["id"], journey.master.id)
      if pattern.nil?
        pattern = Pattern.new(:master => journey.master, :api => api, :route => journey.route)
      end
      pattern.from_hash(resp["Route"])
      journey.pattern = pattern
      pattern.save
    end
  end

  def update_route(route)
    api = route.api
    url = api.get_route_definition
    url = "#{url}?id=#{route.persistentid}&type=R"
    resp = Hash.from_xml open(url)
    if resp["Route"]
      route.from_hash(resp["Route"])
      for p in route.patternids do
        update_route_patterns(api, p, route)
      end
      route.save
    end
    return route
  end

  def update_route_patterns(api, p, route)
    url  = api.get_route_definition
    url  = "#{url}?id=#{p}&type=P"
    resp = Hash.from_xml open(url)
    if resp["Route"]
      pattern = Pattern.find_by_persistentid_and_master_id(resp["Route"]["id"], route.master.id)
      if pattern.nil?
        pattern = Pattern.new(:master => route.master, :api => api, :route => route)
      end
      pattern.from_hash(resp["Route"])
      pattern.save
    end
  end
end