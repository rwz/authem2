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

  specify "#current_customer returns nil" do
    get :show_current_customer
    expect(response.body).to eq("nil")
  end

  specify "sign_in :as can sign in user as customer" do
    get :sign_in_customer_jane
    get :show_current_customer
    expect(response.body).to include("jane@example.com")
  end

  specify "user can be signed in as user and customer at the same time" do
    get :sign_in_as_joe
    get :sign_in_customer_jane

    get :show_current_user
    expect(response.body).to include("joe@example.com")

    get :show_current_customer
    expect(response.body).to include("jane@example.com")
  end

  specify "works with namespaced models" do
    get :sign_in_as_admin
    get :show_current_admin

    expect(response.body).to include("admin@example.com")
    expect(response.body).to include("MyNamespace::SuperUser")
  end
end
