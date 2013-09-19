class Api < ActiveRecord::Base
  serialize :box, Array

  def from_hash(hash)
    hash.each_pair do |k,v|
      case k
        when "update"
          self.a_update= v
        when /oauth/
        when "time"
          self.time = Time.new(v.to_i)
        when "timeoffset"
          self.time_offset= v
        when "box"
          self.box = v.split(",").map {|x| x.to_f}
        when "Message"
          # Not fully realized yet.
          message = Message.new
          message.from_hash(v)
        else
          self.send("#{k.underscore}=", v)
      end
    end
  end

end
