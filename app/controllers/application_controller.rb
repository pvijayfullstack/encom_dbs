class ApplicationController < ActionController::Base

  protect_from_forgery

  around_filter :cache_other_db_connections

  private

  def cache_other_db_connections
    MysqlBase.connection.cache { yield }
  end

end
