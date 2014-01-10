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

    def get_authem_name_for(model)
      raise ArgumentError if model.nil?

      given_klass = model.class
      match = settings.each_with_object([]) do |(name, klass), array|
        array << name if given_klass == klass
      end

      raise UnknownEntityError.new(model) if match.empty?
      raise AmbigousEntityError.new(model, match) unless match.one?

      match.first
    end

    def define_authem(name, options = {})
      method_name = "current_#{name}"
      session_key = "authem_#{method_name}"
      ivar_name   = "@_#{session_key}"
      klass       = options.fetch(:model){ name.to_s.classify.constantize }

      self.settings ||= {}
      self.settings = settings.merge(name.to_sym => klass)

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

        define_method "sign_in_#{name}" do |model|
          raise ArgumentError if model.nil?
          instance_variable_set ivar_name, model
          session[session_key] = model[model.class.primary_key]
        end

        define_method "sign_out_#{name}" do
          instance_variable_set ivar_name, nil
          session.delete session_key
        end
      end
    end

    protected

    def settings
      controller.authem_settings
    end

    def settings=(value)
      controller.authem_settings = value
    end

  end
end
