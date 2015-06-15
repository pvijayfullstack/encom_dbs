require 'test_helper'

class Scenerio1Test < ActiveSupport::TestCase

  let(:user_new) { MysqlUser.new email: 'foo@bar.com' }

  # MySQL:  BEGIN
  # MySQL:  INSERT INTO `users` (`created_at`, `email`, `updated_at`) VALUES ('2015-06-14 16:57:24', 'foo@bar.com', '2015-06-14 16:57:24')
  #  Base:  BEGIN
  #  Base:  INSERT INTO "accounts" ("created_at", "email", "updated_at") VALUES ('2015-06-14 16:57:24.100117', 'foo@bar.com', '2015-06-14 16:57:24.100117') RETURNING "id"
  #  Base:  COMMIT
  # MySQL:  COMMIT

  it 'basic model cross db save - using after_save' do
    user_new.account_create = true
    assert user_new.save
    sql_matching(/BEGIN/).length.must_equal 2
    sql_matching(/COMMIT/).length.must_equal 2
    assert Account.where(email: user_new.email).exists?
  end

end
