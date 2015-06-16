module EncomDbsSQLHelper

  def clear_subscriber_logs
    SQLSubscriber.clear_log
    SQLCacheSubscriber.clear_log
  end

  class SQLSubscriber
    class_attribute :log ; self.log = []
    def self.clear_log ; self.log = [] ; end
    def call(name, start, finish, message_id, values)
      sql = values[:sql]
      return if 'CACHE' == values[:name]
      self.class.log << sql
    end
  end

  def sql_log
    SQLSubscriber.log
  end

  def sql_matching(pattern)
    sql_log.select { |sql| pattern === sql }
  end

  class SQLCacheSubscriber < SQLSubscriber
    self.log = []
    def call(name, start, finish, message_id, values)
      return if 'CACHE' != values[:name]
      log << values[:sql]
    end
  end

  def sql_cache_log
    SQLCacheSubscriber.log
  end

  ActiveSupport::Notifications.subscribe 'sql.active_record', SQLSubscriber.new
  ActiveSupport::Notifications.subscribe 'sql.active_record', SQLCacheSubscriber.new

end
