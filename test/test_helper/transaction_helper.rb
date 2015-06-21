ActiveRecord::Base.class_eval do

  def self.multi_transaction
    ActiveRecord::Base.transaction do
      MysqlBase.transaction { yield }
    end
  end

  def multi_transaction
    self.class.multi_transaction { yield }
  end

end
