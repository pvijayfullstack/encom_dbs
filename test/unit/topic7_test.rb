require 'test_helper'

class Topic7Test < ActionDispatch::IntegrationTest

  self.use_transactional_fixtures = true

  before {
    MysqlBase.connection.increment_open_transactions
    MysqlBase.connection.transaction_joinable = false
    MysqlBase.connection.begin_db_transaction
  }
  before { clear_subscriber_logs ; spaceout_log }
  after  {
    if MysqlBase.connection.open_transactions != 0
      MysqlBase.connection.rollback_db_transaction
      MysqlBase.connection.decrement_open_transactions
    end
  }

  it 'implicit cross model' do
    new_mysql_user.account_create = true
    assert new_mysql_user.save!
    assert Account.where(email: new_mysql_user.email).exists?
    sql_log_matching(/\ASAVEPOINT active_record/).length.must_equal 2
    sql_log_matching(/\ARELEASE SAVEPOINT active_record/).length.must_equal 2
  end


end
