class Message < ActiveRecord::Base

  def from_hash(hash)
    attrs = hash["Message"]

    attrs.each_pair do |k,v|
      case k
        when "id"
          self.persistentid= v
        when "expiryTime"
          self.expiry_time = Time.at(v.to_i)

        else
          self.send("#{k.underscore}=", v)
      end
    end
  end
end
