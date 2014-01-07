require "controller_spec_helper"

describe AuthemController do
  it "has current_user method" do
    get :show_current_user
    expect(response.body).to eq("nil")
  end
end
