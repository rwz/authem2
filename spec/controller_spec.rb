require "spec_helper"


describe Authem::Controller do
  BaseController = Class.new{ include Authem::Controller }
  let(:session){ HashWithIndifferentAccess.new }
  let(:controller){ controller_klass.new }
  let(:another_controller) do
    controller_klass.new.tap do |instance|
      instance.stub(session: controller.session)
    end
  end

  before { controller.stub(session: session) }

  context "with one entity" do
    let(:user) { User.create(email: "joe@example.com") }
    let(:controller_klass) do
      Class.new(BaseController) { authem_for :user }
    end

    it "has current_user method" do
      expect(controller).to respond_to(:current_user)
    end

    it "has sign_in_user method" do
      expect(controller).to respond_to(:sign_in_user)
    end

    it "can sign in user using sign_in_user method" do
      controller.sign_in_user user
      expect(controller.current_user).to eq(user)
      expect(another_controller.current_user).to eq(user)
    end

    it "can sing in usin sign_in method" do
      expect(controller).to receive(:sign_in_user).with(user)
      controller.sign_in user
    end

    it "raises an error when trying to sign in unknown model" do
      model = MyNamespace::SuperUser.create(email: "admin@example.com")
      message = "Unknown authem entity: #{model.inspect}"
      expect{ controller.sign_in model }.to raise_error(Authem::UnknownEntityError, message)
    end

    it "raises an error when trying to sign in nil" do
      expect{ controller.sign_in nil }.to raise_error(ArgumentError)
      expect{ controller.sign_in_user nil }.to raise_error(ArgumentError)
    end

    it "has sign_out_user method" do
      expect(controller).to respond_to(:sign_out_user)
    end

    context "when user id signed in" do
      before do
        controller.sign_in user
        expect(controller.current_user).to eq(user)
      end

      it "can sign out using sign_out_user method" do
        controller.sign_out_user
        expect(controller.current_user).to be_nil
        expect(another_controller.current_user).to be_nil
      end

      it "can sign out using sign_out method" do
        controller.sign_out user
        expect(controller.current_user).to be_nil
        expect(another_controller.current_user).to be_nil
      end
    end

    it "raises an error when calling sign_out with nil" do
      expect{ controller.sign_out nil }.to raise_error(ArgumentError)
    end
  end

  context "with multiple entities" do
    let(:admin){ MyNamespace::SuperUser.create(email: "admin@example.com") }
    let(:controller_klass) do
      Class.new(BaseController) do
        authem_for :user
        authem_for :admin, model: MyNamespace::SuperUser
      end
    end

    it "has current_admin method" do
      expect(controller).to respond_to(:current_admin)
    end

    it "has sign_in_admin method" do
      expect(controller).to respond_to(:sign_in_admin)
    end

    it "can sign in admin using sign_in_admin method" do
      controller.sign_in_admin admin
      expect(controller.current_admin).to eq(admin)
      expect(another_controller.current_admin).to eq(admin)
    end

    it "can sign in using sing_in method" do
      expect(controller).to receive(:sign_in_admin).with(admin)
      controller.sign_in admin
    end

    context "with signed in user and admin" do
      let(:user){ User.create(email: "joe@example.com") }
      before do
        controller.sign_in_user user
        controller.sign_in_admin admin
      end

      after do
        expect(controller.current_admin).to eq(admin)
        expect(another_controller.current_admin).to eq(admin)
      end

      it "can sign out user separately from admin using sign_out_user" do
        controller.sign_out_user
      end

      it "can sign out user separately from admin using sign_out" do
        controller.sign_out user
      end
    end
  end

  context "multiple entities with same model class" do
    let(:user){ User.create(email: "joe@example.com") }
    let(:customer){ User.create(email: "shmoe@example.com") }
    let(:controller_klass) do
      Class.new(BaseController) do
        authem_for :user
        authem_for :customer, model: User
      end
    end

    it "can sign in user separately from customer" do
      controller.sign_in_user user
      expect(controller.current_user).to eq(user)
      expect(controller.current_customer).to be_nil
      expect(another_controller.current_user).to eq(user)
      expect(another_controller.current_customer).to be_nil
    end

    it "can sign in customer and user separately" do
      controller.sign_in_user user
      controller.sign_in_customer customer
      expect(controller.current_user).to eq(user)
      expect(controller.current_customer).to eq(customer)
      expect(another_controller.current_user).to eq(user)
      expect(another_controller.current_customer).to eq(customer)
    end

    it "raises the error when sign in can't guess the model properly" do
      message = "Ambigous match for #{user.inspect}: user, customer"
      expect{ controller.sign_in user }.to raise_error(Authem::AmbigousEntityError, message)
    end

    it "raises the error when sign out can't guess the model properly" do
      message = "Ambigous match for #{user.inspect}: user, customer"
      expect{ controller.sign_out user }.to raise_error(Authem::AmbigousEntityError, message)
    end
  end
end
