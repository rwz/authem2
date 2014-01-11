require "active_record"

module Authem
  ActiveSupport.on_load :active_record do
    class Session < ::ActiveRecord::Base
      self.table_name = :authem_sessions

      belongs_to :subject, polymorphic: true
      scope :by_subject, ->(model){ where(subject_type: model.class.name, subject_id: model.id) }
      scope :active, ->{ where(arel_table[:expires_at].gteq(Time.now)) }
      scope :expired, ->{ where(arel_table[:expires_at].lt(Time.now)) }
      attr_writer :ttl

      before_save do
        self.token ||= SecureRandom.hex(40)
        self.expires_at ||= ttl.from_now
      end

      def ttl
        @ttl ||= 30.days
      end
    end
  end
end
