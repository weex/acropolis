# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe RegistrationsController, type: :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let(:language) { I18n.locale.to_s }
  let(:code) {InvitationCode.create(user: bob)}
  let(:valid_params) {
    {
      user: {
        username:              "jdoe",
        email:                 "jdoe@example.com",
        password:              "password",
        password_confirmation: "password",
        language:              language
      }
    }
  }

  describe "#check_registrations_open_or_valid_invite!" do
    before do
      AppConfig.settings.enable_registrations = false
    end

    it "redirects #new to the registrations closed page" do
      get :new
      expect(response).to redirect_to registrations_closed_path
    end

    it "redirects #create to the registrations closed page" do
      post :create, params: valid_params
      expect(response).to redirect_to registrations_closed_path
    end

    it "does not redirect if there is a valid invite token" do
      get :new, params: {invite: {token: code.token}}
      expect(response).not_to be_redirect
    end

    it "does redirect if there is an invalid invite token" do
      get :new, params: {invite: {token: "fssdfsd"}}
      expect(flash[:error]).to eq(I18n.t("registrations.invalid_invite"))
      expect(response).to redirect_to registrations_closed_path
    end

    it "does redirect if there are no invites available with this code" do
      code.update_attributes(count: 0)

      get :new, params: {invite: {token: code.token}}
      expect(response).to redirect_to registrations_closed_path
    end

    it "does redirect when invitations are closed now" do
      AppConfig.settings.invitations.open = false

      get :new, params: {invite: {token: code.token}}
      expect(response).to redirect_to registrations_closed_path
    end

    it "does not redirect when the registration is open" do
      AppConfig.settings.enable_registrations = true

      code.update_attributes(count: 0)

      get :new, params: {invite: {token: code.token}}
      expect(response).not_to be_redirect
    end
  end

  describe "#create" do
    render_views

    context "with valid parameters" do
      subject do
        post :create, params: valid_params
      end

      it "creates a user" do
        subject
        user = User.find_by(email: 'jdoe@example.com')
        expect(user).to_not be_nil
        expect(user.language).to eq(language)
      end

      it "assigns @user" do
        subject
        expect(assigns(:user)).to be_truthy
      end

      it "sets the flash" do
        subject
        expect(flash[:notice]).not_to be_blank
      end

      it 'redirects to login path' do
        subject
        expect(response).to redirect_to login_path
      end

      context "with invite code" do
        subject do
          post :create, params: valid_params
        end

        it "reduces number of available invites when the registration is closed" do
          AppConfig.settings.enable_registrations = false
          expect {
            post :create, params: valid_params.merge(invite: {token: code.token})
          }.to change { code.reload.count }.by(-1)
        end

        it "doesn't reduce number of available invites when the registration is open" do
          expect {
            post :create, params: valid_params.merge(invite: {token: code.token})
          }.not_to change { code.reload.count }
        end

        it "links inviter with the user" do
          post :create, params: valid_params.merge(invite: {token: code.token})
          expect(User.find_by(username: "jdoe").invited_by).to eq(bob)
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { valid_params.deep_merge(user: {password_confirmation: "baddword"}) }

      it "does not create a user" do
        expect { get :create, params: invalid_params }.not_to change(User, :count)
      end

      it "does not create a person" do
        expect { get :create, params: invalid_params }.not_to change(Person, :count)
      end

      it "assigns @user" do
        get :create, params: invalid_params
        expect(assigns(:user)).not_to be_nil
      end

      it "sets the flash error" do
        get :create, params: invalid_params
        expect(flash[:error]).not_to be_blank
      end

      it "doesn't reduce number of available invites" do
        AppConfig.settings.enable_registrations = false
        expect {
          get :create, params: invalid_params.merge(invite: {token: code.token})
        }.not_to change { code.reload.count }
      end

      it "renders new" do
        get :create, params: invalid_params
        expect(response).to render_template("registrations/new")
      end

      it "keeps invalid params in form" do
        get :create, params: invalid_params
        expect(response.body).to match /jdoe@example.com/m
      end
    end
  end
end
