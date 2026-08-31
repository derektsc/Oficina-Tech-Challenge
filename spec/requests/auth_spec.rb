# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Auth", type: :request do
  it "autentica administrador com JWT" do
    user = create(:user, email: "admin@oficina.test", password: "oficina123")

    post "/api/v1/auth/login", params: { email: user.email, password: "oficina123" }

    expect(response).to have_http_status(:ok)
    expect(json_body["token"]).to be_present
  end

  it "recusa credenciais inválidas" do
    post "/api/v1/auth/login", params: { email: "x@y.com", password: "nope" }
    expect(response).to have_http_status(:unauthorized)
  end

  it "protege rotas administrativas" do
    get "/api/v1/admin/customers"
    expect(response).to have_http_status(:unauthorized)
  end
end
