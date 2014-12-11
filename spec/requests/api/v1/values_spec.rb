require 'rails_helper'

RSpec.describe 'Values API' do
  let(:project) { FactoryGirl.create(:project) }
  let(:user) { FactoryGirl.create(:user, with_projects: [project]) }
  let(:other_user) { FactoryGirl.create(:user) }

  let(:common_headers) { { 'CONTENT_TYPE' => Mime::JSON.to_s } }

  describe 'POST /api/v1/projects/:project_id/values' do
    let(:url) { "/api/v1/projects/#{project.slug}/values" }

    it 'responses with 401 error for non authorized user' do
      post url, {}, common_headers
      expect(response.status).to eq(401)
    end

    it 'responses with 403 error for user without permission' do
      post url, {}, user_headers(other_user, common_headers)
      expect(response.status).to eq(403)
      expect(response.body).to eq('Access denied')
    end

    context 'valid data' do
      let(:headers) { user_headers(user, common_headers) }
      let(:action) { post url, data.to_json, headers }

      shared_context 'successfull request' do
        it 'responds with 201' do
          action
          expect(response.status).to eq(201)
        end
      end

      context 'use new SKU' do
        let(:data) { { item: { sku: Time.now.to_i.to_s, name: 'New item' }, value: { value: 0, timestamp: '2014-01-01 00:00:00' } } }

        it_behaves_like 'successfull request'

        it 'creates new item' do
          expect { action }.to change(Item, :count).by(1)
          item = Item.last
          expect(item.sku).to eq data[:item][:sku]
          expect(item.name).to eq data[:item][:name]
        end

        it 'responds with JSON' do
          expected_response = {
            value: {
              value: data[:value][:value].to_f,
              timestamp: '2014-01-01T00:00:00.000Z',
              item: {
                sku: data[:item][:sku],
                name: data[:item][:name]
              }
            }
          }
          action
          expect(response.body).to eq(expected_response.to_json)
        end
      end

      context 'use SKU of the existing item' do
        let!(:item) { FactoryGirl.create(:item, project: project) }
        let(:data) { { item: { sku: item.sku, name: 'It should not change!' }, value: { value: 0, timestamp: '2014-01-01 00:00:00' } } }

        it_behaves_like 'successfull request'

        it 'does not create new item' do
          expect { action }.not_to change(Item, :count)
        end

        it 'responds with JSON' do
          expected_response = {
            value: {
              value: data[:value][:value].to_f,
              timestamp: '2014-01-01T00:00:00.000Z',
              item: {
                sku: item.sku,
                name: item.name
              }
            }
          }
          action
          expect(response.body).to eq(expected_response.to_json)
        end
      end
    end

    context 'unprocessable data' do
      let(:headers) { user_headers(user, common_headers) }
      let(:action) { post url, data.to_json, headers }
      let(:data) { { item: { sku: Time.now.to_i.to_s, name: 'New item' }, value: { value: nil } } }

      it 'responds with 422 code' do
        action
        expect(response.status).to eq(422)
      end

      it 'does not create any values' do
        expect { action }.not_to change(Value, :count)
      end

      it 'renders errors list' do
        action
        expected_response = { value: ["can't be blank"], timestamp: ["can't be blank"] }
        expect(response.body).to eq(expected_response.to_json)
      end
    end
  end

end
