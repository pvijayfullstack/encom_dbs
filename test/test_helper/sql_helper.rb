module EncomDbsSQLHelper

  private

  def clear_sqlcounter_log
    SQLCounter.clear_log
  end

  def sqlcounter_log
    SQLCounter.log
  end

  def sql_matching(pattern)
    SQLCounter.log.select { |sql| pattern === sql }
  end

  def capture_sql
    clear_sqlcounter_log
    yield
    SQLCounter.log.dup
  end

  class SQLCounter

    class << self

      attr_accessor :log

      def clear_log
        self.log = []
      end

    end

    clear_log

    def call(name, start, finish, message_id, values)
      sql = values[:sql]
      return if 'CACHE' == values[:name]
      self.class.log << sql
    end

  end

  ActiveSupport::Notifications.subscribe 'sql.active_record', SQLCounter.new

end
