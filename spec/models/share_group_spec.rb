require 'rails_helper'

describe ShareGroup do

  let(:user)        { FactoryGirl.create(:user) }
  let(:dataset)     { Atlas::Dataset::Derived.find(:ameland) }
  let(:share_group) {
    extend ActionDispatch::TestProcess

    ShareGroup.new('cooling_buildings', user, dataset, {
      message: "test", source_attributes: {
        source_file: fixture_file_upload('test.xls')
      }}
    )
  }

  describe 'builds multiple dataset edits' do
    it 'expects a size of 3' do
      expect(share_group.build.length).to eq(3)
    end

    describe 'a dataset edit' do
      let(:dataset_edit) { share_group.build[0] }

      it 'must be of dataset edit type' do
        expect(dataset_edit).to be_a(DatasetEdit)
      end

      it 'must have a key' do
        expect(dataset_edit.key).to eq('buildings_cooling_heatpump_air_water_network_gas_share')
      end
    end
  end

  describe "create" do
    before { share_group.save }

    it 'creates 3 dataset edits' do
      expect(DatasetEdit.count).to eq(3)
    end

    it 'expects a single commit' do
      expect(Commit.count).to eq(1)
    end

    it 'must belong to 3 dataset edits' do
      expect(Commit.last.dataset_edits.count).to eq(3)
    end

    it 'must belong to a user' do
      expect(Commit.last.user).to eq(user)
    end

    it 'must have a message' do
      expect(Commit.last.message).to eq('test')
    end
  end
end
