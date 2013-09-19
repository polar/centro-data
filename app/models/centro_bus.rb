

class CentroBus < ActiveRecord::Base
  #attr_accessible :centroid, :rt, :d, :dd, :dn, :lat, :lon, :pid, :pd, :run, :fs, :op, :dip, :bid, :wid1, :wid2, :time


  def self.make(time, hash)
    hash["centroid"] = hash["id"]
    hash["id"] = nil
    hash["time"] = time
    return CentroBus.create(hash)
  end


end
