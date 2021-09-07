require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe ReferralContactsController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # ReferralContact. As you add validations to ReferralContact, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ReferralContactsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all referral_contacts as @referral_contacts" do
      referral_contact = ReferralContact.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:referral_contacts)).to eq([referral_contact])
    end
  end

  describe "GET show" do
    it "assigns the requested referral_contact as @referral_contact" do
      referral_contact = ReferralContact.create! valid_attributes
      get :show, {:id => referral_contact.to_param}, valid_session
      expect(assigns(:referral_contact)).to eq(referral_contact)
    end
  end

  describe "GET new" do
    it "assigns a new referral_contact as @referral_contact" do
      get :new, {}, valid_session
      expect(assigns(:referral_contact)).to be_a_new(ReferralContact)
    end
  end

  describe "GET edit" do
    it "assigns the requested referral_contact as @referral_contact" do
      referral_contact = ReferralContact.create! valid_attributes
      get :edit, {:id => referral_contact.to_param}, valid_session
      expect(assigns(:referral_contact)).to eq(referral_contact)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ReferralContact" do
        expect {
          post :create, {:referral_contact => valid_attributes}, valid_session
        }.to change(ReferralContact, :count).by(1)
      end

      it "assigns a newly created referral_contact as @referral_contact" do
        post :create, {:referral_contact => valid_attributes}, valid_session
        expect(assigns(:referral_contact)).to be_a(ReferralContact)
        expect(assigns(:referral_contact)).to be_persisted
      end

      it "redirects to the created referral_contact" do
        post :create, {:referral_contact => valid_attributes}, valid_session
        expect(response).to redirect_to(ReferralContact.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved referral_contact as @referral_contact" do
        post :create, {:referral_contact => invalid_attributes}, valid_session
        expect(assigns(:referral_contact)).to be_a_new(ReferralContact)
      end

      it "re-renders the 'new' template" do
        post :create, {:referral_contact => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested referral_contact" do
        referral_contact = ReferralContact.create! valid_attributes
        put :update, {:id => referral_contact.to_param, :referral_contact => new_attributes}, valid_session
        referral_contact.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested referral_contact as @referral_contact" do
        referral_contact = ReferralContact.create! valid_attributes
        put :update, {:id => referral_contact.to_param, :referral_contact => valid_attributes}, valid_session
        expect(assigns(:referral_contact)).to eq(referral_contact)
      end

      it "redirects to the referral_contact" do
        referral_contact = ReferralContact.create! valid_attributes
        put :update, {:id => referral_contact.to_param, :referral_contact => valid_attributes}, valid_session
        expect(response).to redirect_to(referral_contact)
      end
    end

    describe "with invalid params" do
      it "assigns the referral_contact as @referral_contact" do
        referral_contact = ReferralContact.create! valid_attributes
        put :update, {:id => referral_contact.to_param, :referral_contact => invalid_attributes}, valid_session
        expect(assigns(:referral_contact)).to eq(referral_contact)
      end

      it "re-renders the 'edit' template" do
        referral_contact = ReferralContact.create! valid_attributes
        put :update, {:id => referral_contact.to_param, :referral_contact => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested referral_contact" do
      referral_contact = ReferralContact.create! valid_attributes
      expect {
        delete :destroy, {:id => referral_contact.to_param}, valid_session
      }.to change(ReferralContact, :count).by(-1)
    end

    it "redirects to the referral_contacts list" do
      referral_contact = ReferralContact.create! valid_attributes
      delete :destroy, {:id => referral_contact.to_param}, valid_session
      expect(response).to redirect_to(referral_contacts_url)
    end
  end

end
