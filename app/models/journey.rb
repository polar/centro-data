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

  def from_hash(hash)
    hash.each_pair do |k,v|
      case k
        when "id"
          self.persistentid = v
        when "type"
          self.route_type = v
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
