# == Schema Information
#
# Table name: user_authentications
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  authentication_provider_id :integer
#  uid                        :string
#  token                      :string
#  token_expires_at           :datetime
#  params                     :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
class UserAuthentication < ActiveRecord::Base
  belongs_to :user
  belongs_to :authentication_provider

  serialize :params

  def self.create_from_omniauth(params, user, provider)
    token_expires_at =
      if params['credentials']['expires_at']
        Time.zone.at(params['credentials']['expires_at']).to_datetime
      end

    create(
      user: user,
      authentication_provider: provider,
      uid: params['uid'],
      token: params['credentials']['token'],
      token_expires_at: token_expires_at,
      params: params
    )
  end
end
