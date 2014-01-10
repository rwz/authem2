require "active_support/concern"
require "authem/controller_helper"

module Authem
  module Controller
    extend ActiveSupport::Concern

    included{ class_attribute :authem_settings }

    module SignInMethod
      def sign_in(model, options={})
        role = options.fetch(:as){ self.class.get_authem_role_for(model) }
        public_send "sign_in_#{role}", model
      end

      def sign_out(model, options={})
        role = options.fetch(:as){ self.class.get_authem_role_for(model) }
        public_send "sign_out_#{role}"
      end
    end

    module ClassMethods
      def authem_for(model_name, options={})
        include SignInMethod

        authem_controller.define_authem model_name, options
      end

      def get_authem_role_for(model)
        authem_controller.get_authem_role_for(model)
      end

      def authem_controller
        ControllerHelper.new(self)
      end
    end
  end
end
