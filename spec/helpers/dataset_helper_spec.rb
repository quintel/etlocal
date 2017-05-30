require 'rails_helper'

describe DatasetHelper, type: :helper do
  describe 'toggle value for' do
    describe 'with existing ETsource dataset' do
      let(:dataset) { FactoryGirl.create(:dataset) }

      it 'has_industry = false' do
        expect(helper.toggle_value_for(dataset, 'has_industry')).to be true
      end
    end

    describe 'without existing dataset' do
      let(:dataset) { FactoryGirl.create(:dataset, geo_id: 'lutjebroek') }

      let!(:editables) {
        commit = FactoryGirl.create(:commit, dataset: dataset)
        FactoryGirl.create(:dataset_edit, commit: commit, key: 'has_industry', value: 0)
      }

      it 'has_industry = false' do
        expect(helper.toggle_value_for(dataset, 'has_industry')).to be false
      end
    end
  end
end
