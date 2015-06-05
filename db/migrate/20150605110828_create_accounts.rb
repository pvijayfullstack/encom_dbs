class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :email, null: false

      t.timestamps
    end
  end
end
