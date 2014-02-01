require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

class TestMigration < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :email
      t.string :password_digest, limit: 60
    end

    create_table :authem_sessions do |t|
      t.string     :role,       null: false
      t.references :subject,    null: false, polymorphic: true
      t.string     :token,      null: false, limit: 60
      t.datetime   :expires_at, null: false
      t.integer    :ttl,        null: false
      t.timestamps
    end
  end

  def down
    drop_table :users
    drop_table :authem_sessions
  end
end

RSpec.configure do |config|
  config.before(:suite) { TestMigration.new.up }

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
