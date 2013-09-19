class UserLogin < ActiveRecord::Base
  serialize roles, Array
end
