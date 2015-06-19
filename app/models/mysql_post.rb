class MysqlPost < MysqlBase

  self.table_name = :posts

  belongs_to :user, class_name: 'MysqlUser'

  # validates_presence_of :title


end
