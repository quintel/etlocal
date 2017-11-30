require 'rails_helper'

describe AnalyzesDecorator do
  let(:input) {
    { area: { number_of_households: 25 },
      graph_values: {
        preset_demand_setter: {
          agriculture_useful_demand_electricity: 0
        }
      }
    }
  }

  describe "decorates" do
    let(:decorator) { AnalyzesDecorator.decorate(input) }

    it 'the area attributes' do
      expect(decorator.area_attributes).to eq({
        number_of_households: 25
      })
    end

    it 'the graph values' do
      expect(decorator.graph_values).to eq({
        preset_demand_setter: {
          agriculture_useful_demand_electricity: 0
        }
      })
    end
  end
end
