class SchemaTest < ActiveRecord::Migration
  def change
    execute %|ALTER TABLE accounts ADD COLUMN mac macaddr|
  end
end
