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
    # One transaction for MySQL connection.
    mysql_log_matching(/BEGIN/).length.must_equal 1
    mysql_log_matching(/COMMIT/).length.must_equal 1
    # Janky multiple transactions for Base connection.
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
    # One transaction for Base connection.
    base_log_matching(/BEGIN/).length.must_equal 1
    base_log_matching(/COMMIT/).length.must_equal 1
    # Janky multiple transactions for MySQL connection.
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
    # One transaction for MySQL connection.
    mysql_log_matching(/BEGIN/).length.must_equal 1
    mysql_log_matching(/COMMIT/).length.must_equal 1
    # One transaction for Base connection.
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
    # Rollback for MySQL connection.
    mysql_log_matching(/BEGIN/).length.must_equal 1
    mysql_log_matching(/ROLLBACK/).length.must_equal 1
    # Rollback for Base connection.
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
    # Rollback for MySQL connection.
    mysql_log_matching(/BEGIN/).length.must_equal 1
    mysql_log_matching(/COMMIT/).length.must_equal 1
    # Rollback for Base connection.
    base_log_matching(/BEGIN/).length.must_equal 1
    base_log_matching(/COMMIT/).length.must_equal 1
  end




  it 'explicit - outer mysql and base - with autosave association' do
    user = MysqlUser.find(new_user_with_two_new_posts.id) ; spaceout_log
    user.posts[1].title = nil
    user.posts[1].validate_title = true
    # user.posts[1].save!
  end


  private

  def multi_transaction
    MysqlUser.transaction {
      Account.transaction {
        yield
      }
    }
  end

  let(:new_user_with_two_new_posts) do
    new_mysql_user.posts.build title: 'Post 1'
    new_mysql_user.posts.build title: 'Post 2'
    new_mysql_user.save!
    new_mysql_user
  end


end
