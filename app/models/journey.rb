class Journey < ActiveRecord::Base
  belongs_to :api
  belongs_to :pattern
  belongs_to :master
  belongs_to :route

  def bounds
    [nw_lon.to_f, nw_lat.to_f, se_lon.to_f, se_lat.to_f]
  end

  def from_hash(hash)
    hash.each_pair do |k,v|
      case k
        when "type"
          self.route_type = v
        when "curloc"
        when "__content__"
        else
          self.send("#{k.underscore}=", v)
      end
    end

  end
end
