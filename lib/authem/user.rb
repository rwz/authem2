require "authem/token"

module Authem
  module User
    extend ActiveSupport::Concern

    included do
      has_many :authem_sessions, as: :subject, class_name: "Authem::Session"
      has_secure_password

      validates :email, uniqueness: true, format: /\A\S+@\S+\z/

      before_create do
        self.password_reset_token = Authem::Token.generate
      end
    end

    def email=(value)
      super value.try(:downcase)
    end

    def reset_password(password, confirmation)
      if password.blank?
        errors.add :password, :blank
        return false
      end

      self.password = password
      self.password_confirmation = confirmation

      save and update_column :password_reset_token, Authem::Token.generate
    end
  end
end
