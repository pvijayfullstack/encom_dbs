require 'test_helper'

class Scenario1Test < ActiveSupport::TestCase

  let(:user_new) { MysqlUser.new email: 'foo@bar.com' }

  # MySQL:  BEGIN
  # MySQL:  INSERT INTO `users` (`created_at`, `email`, `updated_at`) VALUES ('2015-06-14 16:57:24', 'foo@bar.com', '2015-06-14 16:57:24')
  #  Base:  BEGIN
  #  Base:  INSERT INTO "accounts" ("created_at", "email", "updated_at") VALUES ('2015-06-14 16:57:24.100117', 'foo@bar.com', '2015-06-14 16:57:24.100117') RETURNING "id"
  #  Base:  COMMIT
  # MySQL:  COMMIT

  it 'basic model cross db save' do
    user_new.account_create = true
    assert user_new.save
    sql_matching(/BEGIN/).length.must_equal 2
    sql_matching(/COMMIT/).length.must_equal 2
    assert Account.where(email: user_new.email).exists?
  end

  # MySQL:  BEGIN
  # MySQL:  INSERT INTO `users` (`created_at`, `email`, `updated_at`) VALUES ('2015-06-15 20:59:46', 'foo@bar.com', '2015-06-15 20:59:46')
  #  Base:  BEGIN
  #  Base:  ROLLBACK
  # MySQL:  ROLLBACK

  it 'basic model cross db save - with exception raised' do
    user_new.account_create = true
    user_new.account_fails_validation = true
    refute user_new.save
    sql_matching(/BEGIN/).length.must_equal 2
    sql_matching(/ROLLBACK/).length.must_equal 2
    refute Account.where(email: user_new.email).exists?
  end

end
