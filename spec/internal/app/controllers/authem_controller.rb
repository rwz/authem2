class AuthemController < ApplicationController
  authem_for :user

  def show_current_user
    render text: current_user.inspect
  end

  def sign_in_joe
    # @user = User.new(email: "joe@example.com")
    # sign_in @user
    # render nothing: true
  end
end
