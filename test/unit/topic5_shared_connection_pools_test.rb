require 'test_helper'

class Topic5SharedConnectionPoolsTest < ActionDispatch::IntegrationTest

  it 'uses same pool' do
    my_connection_id = MysqlBase.connection_pool.object_id
    dj_connection_id = Delayed::Backend::ActiveRecord::Job.connection_pool.object_id
    my_connection_id.must_equal dj_connection_id
  end

  it 'uses same connection' do
    my_connection_id = MysqlBase.connection.raw_connection.object_id
    dj_connection_id = Delayed::Backend::ActiveRecord::Job.connection.raw_connection.object_id
    my_connection_id.must_equal dj_connection_id
  end

  it 'uses same new connection in a different thread' do
    current_thread_connection_id = MysqlBase.connection.raw_connection.object_id
    my_connection_id, dj_connection_id = Thread.new {
      [ MysqlBase.connection.raw_connection.object_id,
        Delayed::Backend::ActiveRecord::Job.connection.raw_connection.object_id ]
    }.value
    my_connection_id.wont_equal current_thread_connection_id
    my_connection_id.must_equal dj_connection_id
  end

  it 'can respond to connected and remove_connection properly' do
    my_connection = MysqlBase.connection
    dj_connection = Delayed::Backend::ActiveRecord::Job.connection
    assert my_connection.active?
    assert dj_connection.active?
    begin
      MysqlBase.remove_connection
      refute my_connection.active?
      refute dj_connection.active?
    ensure
      MysqlBase.establish_connection MysqlBase.configurations['mysql'][Rails.env]
    end
  end

end
