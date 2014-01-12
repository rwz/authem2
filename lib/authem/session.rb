require "active_record"

module Authem
  ActiveSupport.on_load :active_record do
    class Session < ::ActiveRecord::Base
      self.table_name = :authem_sessions

      belongs_to :subject, polymorphic: true
      scope :by_subject, ->(model){ where(subject_type: model.class.name, subject_id: model.id) }
      scope :active, ->{ where(arel_table[:expires_at].gteq(Time.now)) }
      scope :expired, ->{ where(arel_table[:expires_at].lt(Time.now)) }

      before_create do
        self.token ||= SecureRandom.hex(40)
        self.ttl ||= 30.days
        self.expires_at ||= ttl_from_now
      end

      def refresh
        self.expires_at = ttl_from_now
        save!
      end

      private

      def ttl_from_now
        ttl.to_i.from_now
      end
    end
  end
end
