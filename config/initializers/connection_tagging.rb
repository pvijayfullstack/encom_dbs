require 'active_record/connection_adapters/abstract_adapter'

ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do

  protected

  def log(sql, name = "SQL", binds = [])
    tagged_name = case adapter_name
                  when 'PostgreSQL' then ' Base: '
                  when 'MySQL' then 'MySQL: '
                  else adapter_name
                  end
    @instrumenter.instrument(
      "sql.active_record",
      :sql           => sql,
      :name          => name,
      :connection_id => object_id,
      :binds         => binds,
      :tagged_name   => tagged_name) { yield }
  rescue Exception => e
    message = "#{e.class.name}: #{e.message}: #{sql}"
    # @logger.debug message if @logger
    exception = translate_exception(e, message)
    exception.set_backtrace e.backtrace
    raise exception
  end

end

require 'active_record/log_subscriber'

ActiveRecord::LogSubscriber.class_eval do

  def sql(event)
    return unless logger.debug?
    payload = event.payload
    return if 'SCHEMA' == payload[:name]
    debug "#{payload[:tagged_name]} #{payload[:sql]}"
  end

end

