ActiveRecord::Base.class_eval do

  def self.multi_transaction
    transaction { MysqlBase.transaction { yield } }
  end

end
