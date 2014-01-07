class AuthemController < ApplicationController
  authem_for :user
  authem_for :customer, model: User
  authem_for :admin, model: MyNamespace::SuperUser

  def show_current_user
    render text: current_user.inspect
  end

  def sign_in_as_joe
    sign_in joe, as: :user
    render nothing: true
  end

  def show_current_customer
    render text: current_customer.inspect
  end

  def sign_in_customer_jane
    sign_in jane, as: :customer
    render nothing: true
  end

  def sign_in_as_admin
    sign_in admin
    render nothing: true
  end

  def show_current_admin
    render text: current_admin.inspect
  end

  private

  def joe
    @joe ||= User.create(email: "joe@example.com")
  end

  def jane
    @jane ||= User.create(email: "jane@example.com")
  end

  def admin
    @admin ||= MyNamespace::SuperUser.create(email: "admin@example.com")
  end
end
