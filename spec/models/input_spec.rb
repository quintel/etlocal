require 'rails_helper'

describe Input do
  it 'fetches all inputs' do
    expect(Input.all.count).to eq(4)
  end
end
