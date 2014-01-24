require "active_support/core_ext/module/delegation"
require "authem/session"
require "authem/errors/ambigous_role"
require "authem/errors/unknown_role"

module Authem
  class Support
    attr_reader :role, :controller

    def initialize(role, controller)
      @role, @controller = role, controller
    end

    def current
      if ivar_defined?
        ivar_get
      else
        ivar_set subject
      end
    end

    def sign_in(record, **options)
      raise ArgumentError if record.nil?
      ivar_set record
      auth_session = Authem::Session.create!(role: role_name, subject: record, ttl: options[:ttl])
      set_token auth_session, options
      auth_session
    end

    def sign_out
      ivar_set nil
      Authem::Session.where(role: role_name, token: auth_token).delete_all
      cookies.delete key, domain: :all
      session.delete key
    end

    def clear_for(record)
      raise ArgumentError if record.nil?
      sign_out
      Authem::Session.by_subject(record).where(role: role_name).delete_all
    end

    private

    delegate :role_name, to: :role
    delegate :cookies, :session, to: :controller

    def set_token(auth_session, **option)
      session[key] = auth_session.token
      if option[:remember]
        cookies.signed[key] = { value: auth_session.token, expires: auth_session.expires_at, domain: :all }
      end
    end

    def subject
      return unless auth_session.present?
      refresh_session && auth_session.subject
    end

    def refresh_session
      auth_session && auth_session.refresh
    end

    def auth_session
      return unless auth_token.present?
      Authem::Session.active.find_by(role: role_name, token: auth_token)
    end

    def auth_token
      session[key] || cookies[key]
    end

    def key
      "authem_current_#{role_name}"
    end

    def ivar_defined?
      controller.instance_variable_defined?(ivar_name)
    end

    def ivar_set(value)
      controller.instance_variable_set ivar_name, value
    end

    def ivar_get
      controller.instance_variable_get ivar_name
    end

    def ivar_name
      @ivar_name ||= "@_#{key}".to_sym
    end
  end
end
