# frozen_string_literal: true

module AuthHelpers
  def auth_headers(user = create(:user))
    token = JsonWebToken.encode(user_id: user.id)
    { "Authorization" => "Bearer #{token}" }
  end

  def json_body
    JSON.parse(response.body)
  end
end
