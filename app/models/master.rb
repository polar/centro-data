class Master < ActiveRecord::Base
  serialize :bounds, Array
end
