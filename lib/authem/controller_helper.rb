require "authem/session"

module Authem
  class AmbigousEntityError < StandardError
    def initialize(model, match)
      message = "Ambigous match for #{model.inspect}: #{match * ', '}"
      super message
    end
  end

  class UnknownEntityError < StandardError
    def initialize(model)
      message = "Unknown authem entity: #{model.inspect}"
      super message
    end
  end

  class ControllerHelper
    attr_reader :controller

    def initialize(controller)
      @controller = controller
    end

    def get_authem_role_for(model)
      raise ArgumentError if model.nil?

      match = settings.each_with_object([]) do |(role, klass), array|
        array << role if model.class == klass
      end

      raise UnknownEntityError.new(model) if match.empty?
      raise AmbigousEntityError.new(model, match) unless match.one?

      match.first
    end

    def define_authem(role, options = {})
      method_name = "current_#{role}"
      session_key = "authem_#{method_name}"
      ivar_name   = "@_#{session_key}"
      klass       = options.fetch(:model){ role.to_s.classify.constantize }

      self.settings = settings.merge(role.to_sym => klass)

      controller.instance_eval do
        define_method method_name do
          if instance_variable_defined?(ivar_name)
            instance_variable_get(ivar_name)
          elsif token = session[session_key]
            authem_session = ::Authem::Session.find_by(role: role, token: token)
            instance_variable_set ivar_name, authem_session.try(:subject)
          else
            instance_variable_set ivar_name, nil
          end
        end

        define_method "sign_in_#{role}" do |model|
          raise ArgumentError if model.nil?

          instance_variable_set ivar_name, model
          authem_session = ::Authem::Session.create!(role: role, subject: model)
          session[session_key] = authem_session.token
        end

        define_method "sign_out_#{role}" do
          instance_variable_set ivar_name, nil

          if token = session[session_key]
            ::Authem::Session.where(role: role, token: token).delete_all
          end

          session.delete session_key
        end
      end
    end

    protected

    def settings=(value)
      controller.authem_settings = value
    end

    def settings
      controller.authem_settings ||= {}
    end
  end
end
