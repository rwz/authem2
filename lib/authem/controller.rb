require "active_support/concern"

module Authem
  module Controller
    extend ActiveSupport::Concern

    module ClassMethods
      def authem_for(model_name, options={})
        method_name = "current_#{model_name}"
        ivar_name   = "@_#{method_name}"
        session_key = "authem_#{method_name}"
        klass       = options.fetch(:model){ model_name.to_s.classify.constantize }

        define_method method_name do
          if instance_variable_defined?(ivar_name)
            return instance_variable_get(ivar_name)
          elsif id = session[session_key]
            model = klass.find(id)
            instance_variable_set ivar_name, model
          else
            instance_variable_set ivar_name, nil
          end
        end
      end
    end
  end
end
