class MysqlPost < MysqlBase

  self.table_name = :posts

  belongs_to :user, class_name: 'MysqlUser'

  attr_accessor :validate_title

  validate :validate_title_do


  private

  def validate_title_do
    errors.add :title, :blank if validate_title
  end

end
