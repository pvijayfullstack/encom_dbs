require 'test_helper'

class Topic7Test < ActionDispatch::IntegrationTest

  self.use_transactional_fixtures = true

  before { MysqlBase.connection.begin_transaction joinable: false }
  before { clear_subscriber_logs ; spaceout_log }
  after  { MysqlBase.connection.rollback_transaction }

  it 'implicit cross model' do
    new_mysql_user.account_create = true
    assert new_mysql_user.save!
    assert Account.where(email: new_mysql_user.email).exists?
    sql_log_matching(/\ASAVEPOINT active_record/).length.must_equal 2
    sql_log_matching(/\ARELEASE SAVEPOINT active_record/).length.must_equal 2
  end


end
