RSpec.shared_examples 'non authenticated request' do
  it 'responses with 401 status code' do
    action
    expect(response.status).to eq(401)
  end
end

RSpec.shared_examples 'unauthorized request' do
  it 'responses with 403 status code' do
    action
    expect(response.status).to eq(403)
    expect(response.body).to eq('Access denied')
  end
end