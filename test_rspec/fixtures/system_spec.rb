# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tenant screen interaction', type: :system do
  it 'uses a JavaScript browser and preserves unsaved input' do
    visit '/screen?identity=reader'
    fill_in 'Draft', with: 'Unsaved text'
    click_button 'Save'
    expect(page).to have_css('#status', text: 'Saved')
    expect(page).to have_field('Draft', with: 'Unsaved text')
  end
end
