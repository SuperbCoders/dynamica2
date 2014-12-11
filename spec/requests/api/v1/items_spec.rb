require 'rails_helper'

RSpec.describe 'PredictedValues API' do
  let(:project) { FactoryGirl.create(:project) }
  let(:item) { FactoryGirl.create(:item, project: project) }
  let(:user) { FactoryGirl.create(:user, with_projects: [project]) }
  let(:other_user) { FactoryGirl.create(:user) }

  let(:common_headers) { { 'CONTENT_TYPE' => Mime::JSON.to_s } }

  shared_examples 'non authorized user' do
    it 'responses with 401 error for non authorized user' do
      delete url, {}, common_headers
      expect(response.status).to eq(401)
    end
  end

  shared_examples 'user without permission' do
    it 'responses with 403 error for user without permission' do
      delete url, {}, user_headers(other_user, common_headers)
      expect(response.status).to eq(403)
      expect(response.body).to eq('Access denied')
    end
  end

  describe 'GET /api/v1/projects/:project_id/items/:id/values' do
    it_behaves_like 'non authorized user'
    it_behaves_like 'user without permission'

    let(:url) { "/api/v1/projects/#{project.slug}/items/#{item.sku}/values" }

    context 'authorized user' do
      let(:headers) { user_headers(user, common_headers) }
      let(:action) { delete url, data.to_json, headers }
      let(:data) { {} }

      before do
        3.times do |i|
          FactoryGirl.create(:value, item: item)
        end
      end

      it 'destroys all the values' do
        expect { action }.to change { Value.count }.by(-3)
      end

      it 'reposnds with 204 code' do
        action
        expect(response.status).to eq(204)
        expect(response.body).to be_blank
      end
    end
  end

end
