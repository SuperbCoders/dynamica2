require 'rails_helper'

RSpec.describe ProfileController, :type => :controller, format: :json do
  clean_database

  user = FactoryGirl.create(:user, name: 'Talipov Corehook')
  other_user = FactoryGirl.create(:user, email: 'other_user@gmail.com')

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end

  describe 'GET #index' do
    it 'should return signed user serialized profile' do
      get :index
      expect(response).to be_success
      expect_json(name: 'Talipov Corehook')
      expect_json(email: user.email)
      expect_json(id: user.id.to_s)
    end
  end

  describe 'POST #update' do
    it 'should update name' do
      post :update, name: 'Other name'
      expect_json(success: true)
      expect(json_body[:profile][:name]).to eq 'Other name'
    end


    it 'should update to email that not exist in db' do
      post :update, email: 'new_email@test.gmail.com'
      expect(response).to be_success
      expect_json(success: true)
      expect(json_body[:profile][:email]).to eq 'new_email@test.gmail.com'
    end

    it 'should not update to email that exist in db' do
      post :update, email: 'other_user@gmail.com'
      expect(response).to be_success
      expect_json(success: false)
    end

  end
end
