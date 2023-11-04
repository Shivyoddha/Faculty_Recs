class AddUsertoForm < ActiveRecord::Migration[7.0]
  def change
    add_reference :forms, :user, foreign_key: true
    add_reference :responses, :user, foreign_key: true
    add_column :users, :adminrole, :boolean
  end
end
