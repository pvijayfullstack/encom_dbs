class MysqlBase < ActiveRecord::Base
  establish_connection configurations['mysql'][Rails.env]
  self.abstract_class = true
end
