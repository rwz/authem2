require "active_record"

module Authem
  ActiveSupport.on_load :active_record do
    class Session < ::ActiveRecord::Base
      self.table_name = :authem_sessions

      belongs_to :subject, polymorphic: true
      scope :by_subject, ->(model){ where(subject_type: model.class.name, subject_id: model.id) }

      before_save do
        self.token ||= SecureRandom.hex(40)
      end
    end
  end
end
