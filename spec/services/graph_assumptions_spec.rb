require 'rails_helper'
require 'support/graph'

describe GraphAssumptions do
  before do
    expect_any_instance_of(Atlas::Runner)
      .to receive(:graph).and_return(
        Graph.new("electricity_consumption").build
      )
  end

  it 'renders defaults for graph values' do
    expect(GraphAssumptions.get('ameland')).to eq({
      households_final_demand_electricity: {
        'households_final_demand_for_appliances_electricity' => 0.6392
      }
    })
  end
end
