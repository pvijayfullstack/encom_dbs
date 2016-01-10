require 'test_helper'

class SecondBaseTest < ActiveSupport::TestCase

  it 'syncs test db' do
    Post.create! title: 'TEST'
    User.create! email: 'test@test.com'
  end

end
