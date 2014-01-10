require "active_record"

module Authem
  ActiveSupport.on_load :active_record do
    class Session < ::ActiveRecord::Base
      self.table_name = :authem_sessions

      belongs_to :subject, polymorphic: true

      before_save do
        self.token ||= SecureRandom.hex(40)
      end
    end
  end
end
