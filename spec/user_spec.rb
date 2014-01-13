require "spec_helper"

describe Authem::User do
  let(:user_klass) do
    Class.new(::ActiveRecord::Base) do
      self.table_name = :users
      include ::Authem::User
    end
  end

  subject{ user_klass.new }
end
