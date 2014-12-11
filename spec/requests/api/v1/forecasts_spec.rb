require 'rails_helper'

RSpec.describe 'Forecasts API' do
  let(:project) { FactoryGirl.create(:project) }
  let(:item) { FactoryGirl.create(:item, project: project) }
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

  describe 'GET /api/v1/projects/:project_id/items/:item_id/forecasts' do
    it_behaves_like 'non authorized user'
    it_behaves_like 'user without permission'

    let(:url) { "/api/v1/projects/#{project.slug}/items/#{item.sku}/forecasts" }

    context 'authorized user' do
      let(:headers) { user_headers(user, common_headers) }
      let(:action) { get url, data.to_json, headers }
      let(:another_item) { FactoryGirl.create(:item, project: project) }

      let!(:forecast_1) { FactoryGirl.create(:forecast, item: item) }
      let!(:forecast_2) { FactoryGirl.create(:finished_forecast, item: item) }
      let!(:forecast_3) { FactoryGirl.create(:forecast, item: another_item) }

      context 'without params' do
        let(:data) { {} }

        it 'returns list of all forecasts for the project' do
          action
          expect(response.status).to eq(200)
          expect(json.size).to eq(2)
          expect(json[0][:forecast][:id]).to eq(forecast_1.id)
          expect(json[1][:forecast][:id]).to eq(forecast_2.id)
        end
      end
    end
  end

  describe 'POST /api/v1/projects/:project_id/items/:item_id/forecasts' do
    it_behaves_like 'non authorized user'
    it_behaves_like 'user without permission'

    let(:url) { "/api/v1/projects/#{project.slug}/items/#{item.sku}/forecasts" }

    context 'authorized user' do
      let(:headers) { user_headers(user, common_headers) }
      let(:data) { { forecast: { period: 'day', depth: 3, group_method: 'sum', planned_at: '2014-01-01' } } }
      let(:action) { post url, data.to_json, headers }

      it 'creates new Forecast' do
        expect { action }.to change(Forecast, :count).by(1)
      end

      it 'responds with JSON' do
        action
        expect(response.status).to eq(201)
        expect(json[:forecast][:id]).to eq(Forecast.last.id)
      end
    end
  end

end
