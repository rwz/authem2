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
          elsif id = session[session_key]
            instance_variable_set ivar_name, klass.find(id)
          else
            instance_variable_set ivar_name, nil
          end
        end

        define_method "sign_in_#{role}" do |model|
          raise ArgumentError if model.nil?

          instance_variable_set ivar_name, model
          session[session_key] = model[model.class.primary_key]
        end

        define_method "sign_out_#{role}" do
          instance_variable_set ivar_name, nil
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
