class QuerycacheController < ApplicationController

  def users
    user = -> { MysqlUser.find(params[:user_id]) }
    acct = -> { Account.find(params[:account_id]) }
    render json: {
      accounts: [acct.call, acct.call],
      users: [user.call, user.call]
    }
  end

end

