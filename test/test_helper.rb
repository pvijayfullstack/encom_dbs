ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase

  self.use_transactional_fixtures = false

  before { spaceout_log }
  after  { spaceout_log ; delete_all_data }


  private

  def all_models
    [Account, MysqlUser]
  end

  def delete_all_data
    all_models.each { |model| model.delete_all }
  end

  def spaceout_log
    Rails.logger.debug "\n\n"
  end

end
