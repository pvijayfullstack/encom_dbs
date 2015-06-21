ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'test_helper/sql_helper'
require 'test_helper/transaction_helper'

class ActiveSupport::TestCase

  include EncomDbsSQLHelper

  self.use_transactional_fixtures = false

  before { warm_model_columns ; clear_subscriber_logs ; spaceout_log }
  after  { spaceout_log ; delete_all_data }

  let(:new_mysql_user) { MysqlUser.new email: 'foo@bar.com' }


  private

  def all_models
    [Account, MysqlUser, MysqlPost]
  end

  def warm_model_columns
    all_models.each(&:columns)
  end

  def delete_all_data
    all_models.each(&:delete_all)
  end

  def spaceout_log
    Rails.logger.debug "\n\n"
  end

end
