# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  sign_in_count      :integer          default(0), not null
#  current_sign_in_at :datetime
#  last_sign_in_at    :datetime
#  current_sign_in_ip :inet
#  last_sign_in_ip    :inet
#  provider           :string(100)      not null
#  uid                :string(100)      not null
#  email              :string(255)
#  first_name         :string(255)
#  last_name          :string(255)
#  name               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  deleted_at         :datetime
#  creator_id         :integer
#  updater_id         :integer
#  deleter_id         :integer
#
# Indexes
#
#  index_users_on_deleted_at        (deleted_at)
#  index_users_on_provider_and_uid  (provider,uid) UNIQUE
#

class User < ApplicationRecord
  acts_as_paranoid
  model_stamper

  devise :omniauthable, :trackable

  # Validations
  validates :provider, :presence => true
  validates :uid, :presence => true

  def self.from_omniauth(auth)
    user = User.find_by(:provider => auth.provider, :uid => auth.uid)

    if(!user)
      info = auth.info
      email = info["email"]
      email_domain = email.split("@").last
      if(email_domain == "appalachian.org" || Rails.application.credentials.fetch(:allowed_accounts).include?(email))
        user = User.create!({
          :provider => auth.provider,
          :uid => auth.uid,
          :email => info["email"],
          :first_name => info["first_name"],
          :last_name => info["last_name"],
          :name => info["name"],
        })
      end
    end

    user
  end
end
