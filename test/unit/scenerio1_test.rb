require 'test_helper'

class Scenerio1Test < ActiveSupport::TestCase

  let(:user_new) { MysqlUser.new email: 'foo@bar.com' }

  # BEGIN -- MySQL
  # INSERT INTO `users` (`created_at`, `email`, `updated_at`) VALUES ('2015-06-14 13:15:45', 'foo@bar.com', '2015-06-14 13:15:45')
  # BEGIN -- Base
  # INSERT INTO "accounts" ("created_at", "email", "updated_at") VALUES ('2015-06-14 13:15:45.873674', 'foo@bar.com', '2015-06-14 13:15:45.873674') RETURNING "id"
  # COMMIT -- Base
  # COMMIT -- MySQL

  it 'basic model cross db save - using after_save' do
    user_new.account_create = true
    user_new.save
  end

end
