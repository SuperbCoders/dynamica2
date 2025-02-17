require 'rails_helper'

RSpec.describe ProjectsController, :type => :controller, format: :json do
  clean_database

  user = FactoryGirl.create(:user)
  other_user = FactoryGirl.create(:user)
  project =  FactoryGirl.create(:project, user: user, name: 'TestProject')
  other_project = FactoryGirl.create(:project, user: other_user, name: 'OtherTestProject')


  user.permissions.create(project: project, all: true)

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end


  describe 'POST #search' do
    it 'should return error with invalid slug' do
      post :search, slug: 'no-exist-slug'
      expect(response).not_to be_success
    end

    it 'should not return project which not own' do
      post :search, slug: 'othertestproject'
      expect(response).not_to be_success
    end

    it 'should return own project with slug' do
      post :search, slug: 'testproject'
      expect(response.status).to eq 200
      expect_json(name: 'TestProject')
      expect_json(slug: 'testproject')
    end
  end

  describe 'POST #create' do
    before { post :create, project: { name: 'Second project' } }

    it 'should create project with name' do
      expect(response).to be_success
      expect_json(name: 'Second project')
      expect_json(slug: 'second-project')
      expect_json(user_id: user.id)
    end

    it 'should create project with same name' do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_out user
      sign_in other_user
      second_project = post :create, project: { name: 'Second project'}
      expect(response).to be_success
      expect_json(user_id: other_user.id)
      expect_json(name: 'Second project')
    end
  end

end
