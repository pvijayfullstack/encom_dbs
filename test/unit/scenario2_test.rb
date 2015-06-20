require 'test_helper'

class Scenario2Test < ActiveSupport::TestCase

  # MySQL:  BEGIN
  # MySQL:  INSERT INTO `users` (...) VALUES (...)
  # MySQL:  INSERT INTO `users` (...) VALUES (...)
  #  Base:  BEGIN
  #  Base:  INSERT INTO "accounts" (...) VALUES (...) RETURNING "id"
  #  Base:  COMMIT
  #  Base:  BEGIN
  #  Base:  INSERT INTO "accounts" (...) VALUES (...) RETURNING "id"
  #  Base:  COMMIT
  # MySQL:  COMMIT
  #
  it 'explicit - outer mysql' do
    MysqlUser.transaction do
      MysqlUser.create! email: 'one@one.com'
      MysqlUser.create! email: 'two@two.com'
      Account.create! email: 'one@one.com'
      Account.create! email: 'two@two.com'
    end
    mysql_log_matching(/BEGIN/).length.must_equal 1
    mysql_log_matching(/COMMIT/).length.must_equal 1
    base_log_matching(/BEGIN/).length.must_equal 2
    base_log_matching(/COMMIT/).length.must_equal 2
  end


  #  Base:  BEGIN
  # MySQL:  BEGIN
  # MySQL:  INSERT INTO `users` (...) VALUES (...)
  # MySQL:  COMMIT
  # MySQL:  BEGIN
  # MySQL:  INSERT INTO `users` (...) VALUES (...)
  # MySQL:  COMMIT
  #  Base:  INSERT INTO "accounts" (...) VALUES (...) RETURNING "id"
  #  Base:  INSERT INTO "accounts" (...) VALUES (...) RETURNING "id"
  #  Base:  COMMIT
  #
  it 'explicit - outer base' do
    Account.transaction do
      MysqlUser.create! email: 'one@one.com'
      MysqlUser.create! email: 'two@two.com'
      Account.create! email: 'one@one.com'
      Account.create! email: 'two@two.com'
    end
    base_log_matching(/BEGIN/).length.must_equal 1
    base_log_matching(/COMMIT/).length.must_equal 1
    mysql_log_matching(/BEGIN/).length.must_equal 2
    mysql_log_matching(/COMMIT/).length.must_equal 2
  end


  # MySQL:  BEGIN
  #  Base:  BEGIN
  # MySQL:  INSERT INTO `users` (...)
  # MySQL:  INSERT INTO `users` (...)
  #  Base:  INSERT INTO "accounts" (...) RETURNING "id"
  #  Base:  INSERT INTO "accounts" (...) RETURNING "id"
  #  Base:  COMMIT
  # MySQL:  COMMIT
  #
  it 'explicit - outer mysql and base' do
    MysqlUser.transaction do
      Account.transaction do
        MysqlUser.create! email: 'one@one.com'
        MysqlUser.create! email: 'two@two.com'
        Account.create! email: 'one@one.com'
        Account.create! email: 'two@two.com'
      end
    end
    mysql_log_matching(/BEGIN/).length.must_equal 1
    mysql_log_matching(/COMMIT/).length.must_equal 1
    base_log_matching(/BEGIN/).length.must_equal 1
    base_log_matching(/COMMIT/).length.must_equal 1
  end


  # MySQL:  BEGIN
  #  Base:  BEGIN
  # MySQL:  INSERT INTO `users` (...) VALUES (...)
  #  Base:  ROLLBACK
  # MySQL:  ROLLBACK
  #
  it 'explicit - outer mysql and base - with exception raised' do
    lambda {
      MysqlUser.transaction do
        Account.transaction do
          new_mysql_user.account_create = true
          new_mysql_user.account_fails_validation = true
          new_mysql_user.save!
        end
      end
    }.must_raise ActiveRecord::RecordInvalid
    mysql_log_matching(/BEGIN/).length.must_equal 1
    mysql_log_matching(/ROLLBACK/).length.must_equal 1
    base_log_matching(/BEGIN/).length.must_equal 1
    base_log_matching(/ROLLBACK/).length.must_equal 1
  end


  # MySQL:  BEGIN
  #  Base:  BEGIN
  # MySQL:  INSERT INTO `users` (...) VALUES (...)
  #  Base:  COMMIT
  # MySQL:  COMMIT
  #
  it 'explicit - outer mysql and base - with rollback raised' do
    MysqlUser.transaction do
      Account.transaction do
        new_mysql_user.account_create = true
        new_mysql_user.account_raise_rollback = true
        assert new_mysql_user.save!, 'ActiveRecord::Rollback is not re-raised!'
      end
    end
    mysql_log_matching(/BEGIN/).length.must_equal 1
    mysql_log_matching(/COMMIT/).length.must_equal 1
    base_log_matching(/BEGIN/).length.must_equal 1
    base_log_matching(/COMMIT/).length.must_equal 1
  end


  #  Base:  BEGIN
  # MySQL:  BEGIN
  # MySQL:  SELECT `posts`.* FROM `posts`  WHERE `posts`.`user_id` = ?
  # MySQL:  UPDATE `posts` SET `updated_at` = ?, `title` = NULL WHERE `posts`.`id` = ?
  # MySQL:  ROLLBACK
  #  Base:  ROLLBACK
  #
  it 'explicit - outer base and mysql - with autosave association statement invalid' do
    saved_user_wposts
    begin
      ActiveRecord::Base.multi_transaction do
        saved_user_wposts.posts[1].title = nil
        saved_user_wposts.save!
      end
    rescue ActiveRecord::StatementInvalid => e
      @statement_invalid = true
    end
    assert @statement_invalid
    mysql_log_matching(/BEGIN/).length.must_equal 1
    mysql_log_matching(/ROLLBACK/).length.must_equal 1
    base_log_matching(/BEGIN/).length.must_equal 1
    base_log_matching(/ROLLBACK/).length.must_equal 1
  end

  #  Base:  BEGIN
  # MySQL:  BEGIN
  # MySQL:  SELECT `posts`.* FROM `posts`  WHERE `posts`.`user_id` = ?
  # MySQL:  ROLLBACK
  #  Base:  ROLLBACK
  #
  it 'explicit - outer base and mysql - with autosave association record invalid' do
    saved_user_wposts
    begin
      ActiveRecord::Base.multi_transaction do
        saved_user_wposts.posts[0].title = 'Post 1 [UPDATED]'
        saved_user_wposts.posts[1].title = nil
        saved_user_wposts.posts[1].validate_title = true
        saved_user_wposts.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      @record_invalid = true
    end
    assert @record_invalid
    mysql_log_matching(/BEGIN/).length.must_equal 1
    mysql_log_matching(/ROLLBACK/).length.must_equal 1
    base_log_matching(/BEGIN/).length.must_equal 1
    base_log_matching(/ROLLBACK/).length.must_equal 1
  end



  private

  let(:saved_user_wposts) do
    new_mysql_user.posts.build title: 'Post 1'
    new_mysql_user.posts.build title: 'Post 2'
    new_mysql_user.save!
    MysqlUser.find(new_mysql_user.id).tap do |user|
      clear_subscriber_logs
      spaceout_log
    end
  end

end
