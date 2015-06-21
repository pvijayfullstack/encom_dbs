Delayed::Backend::ActiveRecord::Job.class_eval do

  class << self
    def connection_pool
      MysqlBase.connection_pool
    end
    def retrieve_connection
      MysqlBase.retrieve_connection
    end
    def connected?
      MysqlBase.connected?
    end
    def remove_connection(klass = self)
      MysqlBase.remove_connection
    end
  end

end
