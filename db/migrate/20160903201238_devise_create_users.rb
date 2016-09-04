class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      ## Trackable
      t.integer  :sign_in_count, :default => 0, :null => false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## Omniauthable
      t.string :provider, :limit => 100, :null => false
      t.string :uid, :limit => 100, :null => false
      t.string :email, :limit => 255
      t.string :first_name, :limit => 255
      t.string :last_name, :limit => 255
      t.string :name, :limit => 255

      t.timestamps :null => false
    end

    add_index :users, [:provider, :uid], :unique => true
  end
end
