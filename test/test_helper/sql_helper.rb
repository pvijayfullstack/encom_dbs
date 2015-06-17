module EncomDbsSQLHelper

  def clear_subscriber_logs
    SQLSubscriber.clear_log
    SQLCacheSubscriber.clear_log
    SQLBaseSubscriber.clear_log
    SQLMySQLSubscriber.clear_log
  end

  # Basic Counter

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

  def sql_log_matching(pattern)
    sql_log.select { |sql| pattern === sql }
  end

  ActiveSupport::Notifications.subscribe 'sql.active_record', SQLSubscriber.new

  # Cache Counter

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

  ActiveSupport::Notifications.subscribe 'sql.active_record', SQLCacheSubscriber.new

  # Connection Counter (Base)

  class SQLBaseSubscriber < SQLSubscriber
    self.log = []
    def call(name, start, finish, message_id, values)
      return if values[:tagged_name] !~ /base/i
      log << values[:sql]
    end
  end

  def base_log
    SQLBaseSubscriber.log
  end

  def base_log_matching(pattern)
    base_log.select { |sql| pattern === sql }
  end

  ActiveSupport::Notifications.subscribe 'sql.active_record', SQLBaseSubscriber.new

  # Connection Counter (MySQL)

  class SQLMySQLSubscriber < SQLSubscriber
    self.log = []
    def call(name, start, finish, message_id, values)
      return if values[:tagged_name] !~ /mysql/i
      log << values[:sql]
    end
  end

  def mysql_log
    SQLMySQLSubscriber.log
  end

  def mysql_log_matching(pattern)
    mysql_log.select { |sql| pattern === sql }
  end

  ActiveSupport::Notifications.subscribe 'sql.active_record', SQLMySQLSubscriber.new

end
