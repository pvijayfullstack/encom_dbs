class Account < ActiveRecord::Base

  attr_accessor :fail_validation
  after_validation :check_fail_validation

  class << self

    def create_from_user!(user)
      account = new email: user.email
      account.fail_validation = user.account_fails_validation
      account.save!
    end

  end


  private

  def check_fail_validation
    errors.add :user, 'said to fail validation' if fail_validation
  end


end
