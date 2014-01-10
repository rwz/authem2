require "spec_helper"

describe Authem::Session do
  let(:user){ User.create(email: "joe@example.com") }
  let(:role){ :user }

  it "generates secure token on creation" do
    expect(SecureRandom).to receive(:hex).with(40).and_return("a secure token")
    model = described_class.create(role: role, subject: user)
    expect(model.token).to eq("a secure token")
  end

end
