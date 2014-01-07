class AuthemController < ApplicationController
  authem_for :user

  def show_current_user
    render text: current_user.inspect
  end

  def sign_in_as_joe
    @user = User.create(email: "joe@example.com")
    sign_in @user
    render nothing: true
  end
end
