class Authtoken < ApplicationRecord
    has_secure_token :token
    belongs_to :user

    #It method creates an Authtoken for the User with the various parameters on login/signup
    def self.create_auth_token(user_id,remote_ip, user_agent, device_id)
        Authtoken.where(user_id: user_id).delete_all
        self.create!(user_id: user_id, last_used_at: Time.now.utc, sign_in_ip: remote_ip, user_agent: user_agent, device_id: device_id)
    end

    #It destroyes the authtoke of the user when it logs out
    def self.destroy_auth_token(user_token)
        self.find_by_token(user_token).destroy
    end

    def is_valid?
        return (Time.now.utc - self.last_used_at.utc) / 1.minute <= 15
    end
end
