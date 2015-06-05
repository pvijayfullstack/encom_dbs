class MysqlBase < ActiveRecord::Base
  establish_connection ActiveRecord::Base.configurations['mysql'][Rails.env]
  self.abstract_class = true
end
