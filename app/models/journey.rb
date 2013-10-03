class Journey < ActiveRecord::Base
  include LocationBoxing

  belongs_to :api
  belongs_to :pattern
  belongs_to :master
  belongs_to :route

  belongs_to :centro_bus

  def needs_update?
    return pattern.nil?
  end

  def bounds
    [nw_lon.to_f, nw_lat.to_f, se_lon.to_f, se_lat.to_f]
  end

  # returns feet/min
  def average_speed
    getPathDistance(pattern.coords)/duration # feet/minute
  end

  def p_dist(time_now)
    res =  (average_speed * (time_now - start_time)/60.0) / path_distance * 100
    res = [0,res].max
    res = [res, 100].min
  end

  def sched_time(time_now)
    p_dist(time_now)/100 * average_speed * (time_now - start_time)/60.0
  end

  def start_time
    ActiveSupport::TimeZone.new(time_zone).parse("0:00") + start_offset.minutes
  end

  def end_time
    start_time + duration.minutes
  end

  def active?(time)
    start_time <= time && time <= end_time if time_zone
  end

  def from_hash(hash)
    hash.each_pair do |k,v|
      case k
        when "id"
          self.persistentid = v
        when "type"
          self.route_type = v
        when "distance"
          self.path_distance = v.to_f
        when "curloc"
        when "__content__"
        when "duration"
          self.duration = v.to_i
        else
          self.send("#{k.underscore}=", v)
      end
    end

  end
end
