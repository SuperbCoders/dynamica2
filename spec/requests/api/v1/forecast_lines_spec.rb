require 'rails_helper'

RSpec.describe 'ForecastLines API' do
  let(:project) { FactoryGirl.create(:project) }
  let!(:item_1) { FactoryGirl.create(:item, project: project) }
  let!(:item_2) { FactoryGirl.create(:item, project: project) }
  let(:forecast) { FactoryGirl.create(:finished_forecast, project: project, from: (Time.now - 2.days), to: Time.now) }
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
    let(:action) { get url, {}, user_headers(other_user, common_headers) }

    it 'responses with 403 error for user without permission' do
      action
      expect(response.status).to eq(403)
      expect(response.body).to eq('Access denied')
    end

    it 'does not log anything' do
      expect { action }.not_to change(Log, :count)
    end
  end

  describe 'GET /api/v1/forecasts/:forecast_id/lines' do
    it_behaves_like 'non authorized user'
    it_behaves_like 'user without permission'

    let(:url) { "/api/v1/forecasts/#{forecast.id}/lines" }

    context 'authorized user' do
      let(:headers) { user_headers(user, common_headers) }
      let(:action) { get url, data.to_json, headers }
      let(:data) { {} }

      it 'returns series of original and predicted values' do
        action

        expect(response.status).to eq(200)
        expect(json.size).to eq(3)

        expect(json[0][:forecast_line][:predicted_values].size).to eq(5)
        expect(json[0][:forecast_line][:item][:sku]).to eq(item_1.sku)

        expect(json[1][:forecast_line][:predicted_values].size).to eq(5)
        expect(json[1][:forecast_line][:item][:sku]).to eq(item_2.sku)

        expect(json[2][:forecast_line][:predicted_values].size).to eq(5)
        expect(json[2][:forecast_line][:item]).to be_nil
        expect(json[2][:forecast_line][:summary]).to eq(true)
      end

      it 'logs action' do
        expect { action }.to change(Log, :count).by(1)
        log = Log.order(id: :asc).last
        expect(log.project_id).to eq(project.id)
        expect(log.user_id).to eq(user.id)
        expect(log.data).to eq({ forecast_id: forecast.id })
      end
    end
  end

end
