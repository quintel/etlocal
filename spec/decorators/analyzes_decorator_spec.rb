require 'rails_helper'

describe AnalyzesDecorator do
  let(:input) {
    { number_of_households: 25,
      init: {
        agriculture_useful_demand_electricity: 0
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

    it 'the initializer inputs' do
      expect(decorator.initializer_inputs).to eq({
        'agriculture' => {
          agriculture_useful_demand_electricity: 0
        }
      })
    end
  end
end
