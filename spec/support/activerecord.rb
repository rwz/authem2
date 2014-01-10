require "active_record"

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

class TestMigration < ActiveRecord::Migration
  def up
    create_table :users, force: true do |t|
      t.string :email
    end

    create_table :authem_sessions do |t|
      t.string :role
      t.references :subject, polymorphic: true
      t.string :token, limit: 80
      t.timestamps
    end
  end

  def down
    drop_table :users
    drop_table :authem_sessions
  end
end

class User < ActiveRecord::Base; end

module MyNamespace
  class SuperUser < ActiveRecord::Base
    self.table_name = :users
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
