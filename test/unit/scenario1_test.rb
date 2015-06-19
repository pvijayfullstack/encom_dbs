require 'test_helper'

class Scenario1Test < ActiveSupport::TestCase

  # MySQL:  BEGIN
  # MySQL:  INSERT INTO `users` (...) VALUES (...)
  #  Base:  BEGIN
  #  Base:  INSERT INTO "accounts" (...) VALUES (...) RETURNING "id"
  #  Base:  COMMIT
  # MySQL:  COMMIT
  #
  it 'implicit cross model' do
    new_mysql_user.account_create = true
    assert new_mysql_user.save!
    sql_log_matching(/BEGIN/).length.must_equal 2
    sql_log_matching(/COMMIT/).length.must_equal 2
    assert Account.where(email: new_mysql_user.email).exists?
  end


  # MySQL:  BEGIN
  # MySQL:  INSERT INTO `users` (...) VALUES (...)
  #  Base:  BEGIN
  #  Base:  ROLLBACK
  # MySQL:  ROLLBACK
  #
  it 'implicit cross model - with exception raised' do
    lambda {
      new_mysql_user.account_create = true
      new_mysql_user.account_fails_validation = true
      refute new_mysql_user.save!
    }.must_raise ActiveRecord::RecordInvalid
    sql_log_matching(/BEGIN/).length.must_equal 2
    sql_log_matching(/ROLLBACK/).length.must_equal 2
    refute Account.where(email: new_mysql_user.email).exists?
  end


  # --------
  # TOPIC 3:
  # --------

  # MySQL:  BEGIN
  # MySQL:  INSERT INTO `users` (...) VALUES (...)
  #  Base:  BEGIN
  #  Base:  ROLLBACK
  # MySQL:  COMMIT
  #
  it 'implicit cross model - with rollback raised' do
    new_mysql_user.account_create = true
    new_mysql_user.account_raise_rollback = true
    assert new_mysql_user.save!, 'ActiveRecord::Rollback is not re-raised!'
    sql_log_matching(/BEGIN/).length.must_equal 2
    sql_log_matching(/ROLLBACK/).length.must_equal 1
    sql_log_matching(/COMMIT/).length.must_equal 1
    refute Account.where(email: new_mysql_user.email).exists?
  end

end
