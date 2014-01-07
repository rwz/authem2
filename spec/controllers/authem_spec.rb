require "controller_spec_helper"

describe AuthemController do
  specify "#current_user returns nil" do
    get :show_current_user
    expect(response.body).to eq("nil")
  end

  specify "#sign_in signs in the user" do
    get :sign_in_as_joe
    get :show_current_user
    expect(response.body).to include("joe@example.com")
  end
end
