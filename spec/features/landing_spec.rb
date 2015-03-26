require 'rails_helper'

RSpec.feature 'landing page', js: true do
  scenario 'user visits landing page' do
    visit '/'
    expect(page).to have_content('DYNAMICA')
  end

  scenario 'user clicks Try button' do
    visit '/'
    expect(page).not_to have_selector('#modal-signup', visible: true)
    click_on 'Попробовать бесплатно'
    login_dialog = page.find('#modal-signup', visible: true)
    expect(login_dialog).to have_selector('a', text: 'Sign up', visible: true)
  end
end