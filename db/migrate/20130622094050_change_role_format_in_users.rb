class ChangeRoleFormatInUsers < ActiveRecord::Migration
  def up
    change_column :users, :role, :string
  end

  def down
    change_column :users, :role, :integer
  end
end
