require "authem/session"
require "authem/errors/ambigous_role"
require "authem/errors/unknown_role"

module Authem
  class Support
    attr_reader :controller

    def initialize(controller)
      @controller = controller
    end

    def role_for(model)
      raise ArgumentError if model.nil?

      match = settings.each_with_object([]) do |(role, klass), array|
        array << role if model.class == klass
      end

      raise UnknownRoleError.new(model) if match.empty?
      raise AmbigousRoleError.new(model, match) unless match.one?

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
          elsif token = session[session_key] || cookies.signed[session_key]
            authem_session = ::Authem::Session.active.find_by(role: role, token: token)
            subject = authem_session && authem_session.refresh && authem_session.subject
            instance_variable_set ivar_name, subject
          else
            instance_variable_set ivar_name, nil
          end
        end

        define_method "sign_in_#{role}" do |model, **options|
          raise ArgumentError if model.nil?

          instance_variable_set ivar_name, model
          remember = options.fetch(:remember, false)
          authem_session = ::Authem::Session.create!(role: role, subject: model, ttl: options[:ttl])
          token = authem_session.token
          session[session_key] = token
          if remember
            cookie_value = { value: token, expires: authem_session.expires_at }
            cookies.signed[session_key] = cookie_value
          end
          authem_session
        end

        define_method "sign_out_#{role}" do
          instance_variable_set ivar_name, nil

          if token = session[session_key]
            ::Authem::Session.where(role: role, token: token).delete_all
          end

          session.delete session_key
        end

        define_method "clear_all_#{role}_sessions_for" do |model|
          raise ArgumentError if model.nil?
          public_send "sign_out_#{role}"
          ::Authem::Session.by_subject(model).where(role: role).delete_all
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
