module Authem
  module User
    extend ActiveSupport::Concern

    included do
      has_many :authem_sessions, as: :subject, class_name: "Authem::Session"
      has_secure_password

      validates :email,
        uniqueness: true,
        format: /\A\S+@\S+\z/
    end

    def email=(value)
      super value.try(:downcase)
    end
  end
end
