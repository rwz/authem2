require "spec_helper"

describe Authem::User do

  class TestUser < ActiveRecord::Base
    self.table_name = :users
    include Authem::User
  end

  let(:user_klass) { TestUser }

  it "downcases email" do
    record = user_klass.new
    record.email = "JOE@EXAMPLE.COM"
    expect(record.email).to eq("joe@example.com")
  end

  context "#authenticate" do
    subject { user_klass.create(email: "joe@example.com", password: "secret", password_confirmation: "secret")  }

    it "returns record if password is correct" do
      expect(subject.authenticate("secret")).to eq(subject)
    end

    it "returns false if password is incorrect" do
      expect(subject.authenticate("notright")).to be_false
    end

    it "returns false if password is nil" do
      expect(subject.authenticate(nil)).to be_false
    end
  end

  context "validations" do
    it "allows properly formatted emails" do
      record = user_klass.create(email: "joe@example.com")
      expect(record.errors).not_to include(:email)
    end

    it "validates email presence" do
      record = user_klass.create(email: nil)
      expect(record.errors).to include(:email)
    end

    it "validates email format" do
      record = user_klass.create(email: "joe-at-example-com")
      expect(record.errors).to include(:email)
    end

    it "validates email uniqueness" do
      user_klass.create(email: "joe@example.com", password: "123", password_confirmation: "123")
      record = user_klass.create(email: "JOE@EXAMPLE.COM")
      expect(record.errors).to include(:email)
    end
  end
end
