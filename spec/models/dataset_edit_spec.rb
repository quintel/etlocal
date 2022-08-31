require 'rails_helper'

describe DatasetEdit do
  before { dataset_edit.valid? }

  describe "blank dataset edit" do
    let(:dataset_edit) { DatasetEdit.new }

    it "can't have a blank value" do
      expect(dataset_edit).to have(1).errors_on(:value)
    end

    it "can't have a blank key" do
      expect(dataset_edit).to have(1).errors_on(:key)
    end
  end

  describe "must be bigger than or 0" do
    describe "for regular attribute" do
      let(:dataset_edit) { DatasetEdit.new(value: 0) }

      it "is invalid" do
        expect(dataset_edit).to have(0).errors_on(:value)
      end
    end
  end

  describe 'when the edit has a dataset' do
    let(:dataset_edit) do
      described_class.new(
        key: 'thing',
        value: 10,
        commit: FactoryBot.build(:commit)
      )
    end

    context 'with a DB dataset' do
      it 'has no errors on the value' do
        expect(dataset_edit).to have(:no).errors_on(:value)
      end
    end

    context 'with an energy_balance dataset' do
      before do
        dataset_edit.commit.dataset.data_source = 'energy_balance'
      end

      it 'has no errors when editing and not using a query' do
        allow(EditableAttributesCollection).to receive(:item).with('thing').and_return(
          EditableAttribute.new(dataset_edit.commit.dataset, :thing, [], nil)
        )

        expect(dataset_edit).to have(:no).errors_on(:value)
      end

      it 'has an error editing and using a query' do
        allow(EditableAttributesCollection).to receive(:item).with('thing').and_return(
          EditableAttribute.new(
            dataset_edit.commit.dataset,
            :thing,
            [],
            nil,
            energy_balance_query: 'ABC'
          )
        )

        expect(dataset_edit).to have(1).error_on(:value)
      end
    end
  end

  describe '#creator' do
    let(:dataset_edit) { DatasetEdit.new(value: 0, commit: commit) }
    let(:commit) { FactoryBot.create(:commit, user: user) }

    context 'with a creator without a group' do
      let(:user) { FactoryBot.create(:user, group: nil) }
      it 'is the users name' do
        expect(dataset_edit.creator).to eq(user.name)
      end
    end

    context 'with a creator without a group' do
      let(:user) { FactoryBot.create(:user) }
      it 'is the users name' do
        expect(dataset_edit.creator).to eq(user.group.key.humanize)
      end
    end
  end
end
