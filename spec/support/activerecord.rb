require 'active_record'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

class TestMigration < ActiveRecord::Migration
  def up
    create_table :users, force: true do |t|
      t.column :email, :string
    end
  end

  def down
    drop_table :primary_strategy_users
  end
end

class User < ActiveRecord::Base
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
