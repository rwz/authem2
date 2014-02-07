require "spec_helper"

describe Authem::User do

  class TestUser < ActiveRecord::Base
    self.table_name = :users
    include Authem::User


    def self.create(email: "joe@example.com", password: "password")
      super(
        email:                 email,
        password:              password,
        password_confirmation: password
      )
    end
  end

  it "downcases email" do
    record = TestUser.new
    record.email = "JOE@EXAMPLE.COM"
    expect(record.email).to eq("joe@example.com")
  end

  context "#authenticate" do
    subject{ TestUser.create(password: "secret") }

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
      record = TestUser.create(email: "joe@example.com")
      expect(record.errors).not_to include(:email)
    end

    it "validates email presence" do
      record = TestUser.create(email: nil)
      expect(record.errors).to include(:email)
    end

    it "validates email format" do
      record = TestUser.create(email: "joe-at-example-com")
      expect(record.errors).to include(:email)
    end

    it "validates email uniqueness" do
      TestUser.create email: "joe@example.com"
      record = TestUser.create(email: "JOE@EXAMPLE.COM")
      expect(record.errors).to include(:email)
    end
  end
end
