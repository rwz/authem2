require "active_support/concern"
require "authem/support"

module Authem
  module Controller
    extend ActiveSupport::Concern

    included{ class_attribute :authem_settings }

    module SessionManagementMethods
      def sign_in(model, **options)
        role = options.fetch(:as){ self.class.authem.role_for(model) }
        public_send "sign_in_#{role}", model
      end

      def sign_out(model, **options)
        role = options.fetch(:as){ self.class.authem.role_for(model) }
        public_send "sign_out_#{role}"
      end

      def clear_all_sessions_for(model, **options)
        role = options.fetch(:as){ self.class.authem.role_for(model) }
        public_send "clear_all_#{role}_sessions_for", model
      end
    end

    module ClassMethods
      def authem_for(model_name, **options)
        include SessionManagementMethods

        authem.define_authem model_name, options
      end

      def authem
        Support.new(self)
      end
    end
  end
end
