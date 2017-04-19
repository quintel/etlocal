require 'rails_helper'
require 'support/graph'

describe GraphAssumptions do
  before do
    expect_any_instance_of(Atlas::Runner)
      .to receive(:calculate).and_return(
        Graph.new("electricity_consumption").build
      )
  end

  it 'renders defaults for graph values' do
    expect(GraphAssumptions.get('ameland')).to eq({
      households_final_demand_electricity: {
        'households_final_demand_for_appliances_electricity' => {
          "default" => 0.6392,
          "group"   => "households_final_demand_electricity"
        }
      }
    })
  end
end
