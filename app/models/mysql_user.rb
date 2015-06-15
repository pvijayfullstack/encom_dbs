class MysqlUser < MysqlBase

  self.table_name = :users

  attr_accessor :account_create
  after_save :account_create_do
  attr_accessor :account_fails_validation


  private

  def account_create_do
    return unless account_create
    Account.create_from_user!(self)
  end

end
