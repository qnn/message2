class AddIpAddressToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :ip_address, :string
    add_column :messages, :ip_info, :string
  end
end
