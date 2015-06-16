require 'test_helper'

class Topic2QueryCacheTest < ActionDispatch::IntegrationTest

  let(:user)    { MysqlUser.create! email: 'ken@metaskills.net' }
  let(:account) { Account.create! email: 'ken@metaskills.net' }

  it 'cache queries for the MySQL connection' do
    get querycache_path(user_id: user.id, account_id: account.id, format: :json)
    sql_cache_log[0].must_be :present?
    sql_cache_log[0].must_match %r{accounts}
    sql_cache_log[1].must_be :present?
    sql_cache_log[1].must_match %r{users}
  end

end
