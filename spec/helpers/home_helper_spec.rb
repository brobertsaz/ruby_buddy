require 'rails_helper'

RSpec.describe HomeHelper, type: :helper do
  # HomeHelper is currently empty, but we include this test file
  # for completeness and future helper methods
  
  it 'exists as a module' do
    expect(HomeHelper).to be_a(Module)
  end
end
