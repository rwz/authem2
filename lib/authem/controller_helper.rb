module Authem
  class ControllerHelper
    attr_reader :controller

    def initialize(controller)
      @controller = controller
    end

    def get_authem_name_for(model)
      given_klass = model.class
      match = settings.inject([]) do |memo, (name, klass)|
        memo << name if given_klass == klass
        memo
      end

      raise "Could not sign in #{model.inspect} b/c we don't know wat it is" if match.empty?
      raise "Ambigous match for #{model.inspect} => #{match.inspect}" unless match.one?

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
          instance_variable_set ivar_name, model
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
