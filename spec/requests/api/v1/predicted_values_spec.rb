require 'rails_helper'

RSpec.describe 'PredictedValues API' do
  let(:project) { FactoryGirl.create(:project) }
  let(:item) { FactoryGirl.create(:item, project: project) }
  let(:forecast) { FactoryGirl.create(:finished_forecast, project: project, item: item, from: (Time.now - 2.days), to: Time.now) }
  let(:user) { FactoryGirl.create(:user, with_projects: [project]) }
  let(:other_user) { FactoryGirl.create(:user) }

  let(:common_headers) { { 'CONTENT_TYPE' => Mime::JSON.to_s } }

  shared_examples 'non authorized user' do
    it 'responses with 401 error for non authorized user' do
      get url, {}, common_headers
      expect(response.status).to eq(401)
    end
  end

  shared_examples 'user without permission' do
    it 'responses with 403 error for user without permission' do
      get url, {}, user_headers(other_user, common_headers)
      expect(response.status).to eq(403)
      expect(response.body).to eq('Access denied')
    end
  end

  describe 'GET /api/v1/forecasts/:forecast_id/predicted_values' do
    it_behaves_like 'non authorized user'
    it_behaves_like 'user without permission'

    let(:url) { "/api/v1/forecasts/#{forecast.id}/predicted_values" }

    context 'authorized user' do
      let(:headers) { user_headers(user, common_headers) }
      let(:action) { get url, data.to_json, headers }
      let(:data) { {} }

      it 'returns series of original and predicted values' do
        action
        expect(response.status).to eq(200)
        expect(json.size).to eq(1)
        expect(json[0][:prediction][:predicted_values].size).to eq(5)
      end
    end
  end

end
