class Account < ActiveRecord::Base

  attr_accessor :fail_validation
  after_validation :check_fail_validation

  attr_accessor :raise_rollback
  after_validation :check_raise_rollback

  class << self

    def create_from_user!(user)
      account = new email: user.email
      account.fail_validation = user.account_fails_validation
      account.raise_rollback = user.account_raise_rollback
      account.save!
    end

  end


  private

  def check_fail_validation
    errors.add :user, 'said to fail validation' if fail_validation
  end

  def check_raise_rollback
    raise ActiveRecord::Rollback if raise_rollback
  end

end
