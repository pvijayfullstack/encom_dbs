require 'test_helper'

class TopicConnectionManagementTest < ActiveSupport::TestCase

  class MysqlEstablishConn < ActiveRecord::Base
    establish_connection configurations['mysql'][Rails.env]
  end

  class MysqlSubclassed < MysqlBase
  end

  it 'subclasses share same connection pool while establish_connection does not' do
    connection_id(MysqlSubclassed).must_equal connection_id(MysqlBase)
    connection_id(MysqlSubclassed).wont_equal connection_id(MysqlEstablishConn)
  end


  private

  def connection_id(klass)
    klass.connection.raw_connection.object_id
  end

end
