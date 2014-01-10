require "active_support/concern"
require "authem/controller_helper"

module Authem
  module Controller
    extend ActiveSupport::Concern

    included{ class_attribute :authem_settings }

    module SignInMethod
      def sign_in(model, options={})
        role = options.fetch(:as) do
          controller_helper = Authem::ControllerHelper.new(self.class)
          controller_helper.get_authem_name_for(model)
        end

        public_send "sign_in_#{role}", model
      end

      def sign_out(model, options={})
        role = options.fetch(:as) do
          controller_helper = Authem::ControllerHelper.new(self.class)
          controller_helper.get_authem_name_for(model)
        end

        public_send "sign_out_#{role}"
      end
    end

    module ClassMethods
      def authem_for(model_name, options={})
        include SignInMethod

        controller_helper = Authem::ControllerHelper.new(self)
        controller_helper.define_authem model_name, options
      end
    end
  end
end
