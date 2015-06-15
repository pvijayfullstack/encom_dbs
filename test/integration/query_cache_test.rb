require 'test_helper'

class QueryCacheTest < ActionDispatch::IntegrationTest

  class SQLCacheSubscriber
    class_attribute :log ; self.log = []
    def call(name, start, finish, message_id, values)
      return if 'CACHE' != values[:name]
      log << values[:sql]
    end
  end

  let(:subscriber) { ActiveSupport::Notifications.subscribe 'sql.active_record', SQLCacheSubscriber.new }
  let(:cache_log)  { SQLCacheSubscriber.log }

  let(:user)    { MysqlUser.create! email: 'ken@metaskills.net' }
  let(:account) { Account.create! email: 'ken@metaskills.net' }

  before { subscriber }
  after  { ActiveSupport::Notifications.unsubscribe(subscriber) }

  it 'cache queries for the MySQL connection' do
    get querycache_path(user_id: user.id, account_id: account.id, format: :json)
    cache_log[0].must_be :present?
    cache_log[0].must_match %r{accounts}
    cache_log[1].must_be :present?
    cache_log[1].must_match %r{users}
  end

end
