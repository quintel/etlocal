require 'rails_helper'

describe Dataset do
  let(:dataset) {
    Dataset.create!(name: 'Ameland', parent: 'nl', geo_id: 'AM31049', user: User.robot)
  }

  it "it initializes a dataset from an Atlas dataset" do
    expect(dataset).to be_a(Dataset)
  end

  it "expects a name attribute to be present" do
    expect(dataset.name).to eq("Ameland")
  end

  it 'has a base dataset' do
    expect(dataset.base_dataset).to eq 'nl'
  end

  context 'parent validation' do
    it 'is invalid if parent does not exist in ETsource' do
      ds = Dataset.new(name: 'Ghost', parent: 'not_in_etsource', geo_id: 'ghost1', user: User.robot)
      expect(ds).not_to be_valid
      expect(ds.errors[:parent]).to include('is not included in the list')
    end

    it 'is invalid if parent is nil' do
      ds = Dataset.new(name: 'Orphan', parent: nil, geo_id: 'orphan1', user: User.robot)
      expect(ds).not_to be_valid
      expect(ds.errors[:parent]).to include("can't be blank")
    end

    it 'is invalid if parent is an empty string' do
      ds = Dataset.new(name: 'BlankParent', parent: '', geo_id: 'blank1', user: User.robot)
      expect(ds).not_to be_valid
      expect(ds.errors[:parent]).to include("can't be blank")
    end

    it 'is invalid if parent is not a string' do
      ds = Dataset.new(name: 'NumParent', parent: 123, geo_id: 'num1', user: User.robot)
      expect(ds).not_to be_valid
    end

    it 'is valid if parent exists in ETsource' do
      ds = Dataset.new(name: 'TestChild', parent: 'test_parent', geo_id: 'test_child_geo', user: User.robot)
      expect(ds).to be_valid
    end

    it 'is valid if parent is self (self-referencing dataset)' do
      ds = Dataset.new(name: 'SelfRef', parent: 'test_parent', geo_id: 'test_parent', user: User.robot)
      expect(ds).to be_valid
    end

    it 'is valid for a dataset chain if all parents exist in ETsource' do
      child_dataset = Dataset.create!(name: 'Child', parent: 'test1_ameland', geo_id: 'test_new_child', user: User.robot)

      expect(child_dataset).to be_valid
      expect(child_dataset.parent).to eq('test1_ameland')
    end

    it 'allows shared parents' do
      dataset1 = Dataset.create!(name: 'Dataset1', parent: 'nl', geo_id: 'dataset1', user: User.robot)
      dataset2 = Dataset.create!(name: 'Dataset2', parent: 'test1_ameland', geo_id: 'dataset2', user: User.robot)

      dataset1.parent = 'test1_ameland'
      expect(dataset1).to be_valid
    end
  end

  context 'with a parent not in ETsource' do
    let(:mars_dataset) do
      Dataset.new(
        name: 'Tharsis', parent: 'mars', user: User.robot, geo_id: 'GM666'
      )
    end

    it 'is not valid' do
      expect(mars_dataset.valid?).to be_falsey
    end
  end

  context 'with a parent in ETsource' do
    let(:ameland_dataset) do
      Dataset.new(
        name: 'Ameland', parent: 'nl', user: User.robot, geo_id: 'GM3040'
      )
    end

    it 'is valid' do
      expect(ameland_dataset.valid?).to be_truthy
    end
  end

  describe '.fuzzy_search' do
    subject { described_class.fuzzy_search(query, 'any') }

    before do
      dataset
      eland
    end

    let(:eland) do
      Dataset.create!(name: 'Eland', parent: 'nl', geo_id: 'AM3568', user: User.robot)
    end

    context 'with an exactly matching geo_id query' do
      let(:query) { 'AM31049' }

      it { is_expected.to include(dataset) }
      it { is_expected.to_not include(eland) }
    end

    context 'with an fuzzy matching name query' do
      let(:query) { 'land' }

      it { is_expected.to include(dataset) }
      it { is_expected.to include(eland) }
    end
  end

  describe '#editable_attributes_before' do
    let(:dataset) {
      Dataset.create!(name: 'Ameland', parent: 'nl', geo_id: 'AM31049', user: User.robot)
    }

    it 'returns an EditableAttributesCollection' do
      freeze_time = 2.days.ago

      result = dataset.editable_attributes_before(freeze_time)

      expect(result).to be_a(EditableAttributesCollection)
    end

    it 'passes self and the freeze date to EditableAttributesCollection' do
      freeze_time = 3.days.ago

      expect(EditableAttributesCollection).to receive(:new).with(dataset, freeze_time).and_call_original

      dataset.editable_attributes_before(freeze_time)
    end
  end

  context 'dataset inheritance chain' do
    let!(:root_dataset) do
      Dataset.create!(name: 'Netherlands', geo_id: 'nl', parent: 'nl', user: User.robot)
    end

    let!(:child_dataset) do
      Dataset.create!(name: 'Ameland', parent: 'nl', geo_id: 'test1_ameland', user: User.robot)
    end

    let!(:grandchild_dataset) do
      Dataset.create!(name: 'Urk', parent: 'test1_ameland', geo_id: 'urk', user: User.robot)
    end

    it 'is valid when all ancestors are valid' do
      expect(grandchild_dataset).to be_valid
    end

    it 'has the correct parent hierarchy' do
      expect(grandchild_dataset.parent).to eq('test1_ameland')
      expect(child_dataset.parent).to eq('nl')
      expect(root_dataset.parent).to eq('nl')
    end

    it 'has the correct base dataset (immediate parent)' do
      expect(grandchild_dataset.base_dataset).to eq('test1_ameland')
      expect(child_dataset.base_dataset).to eq('nl')
      expect(root_dataset.base_dataset).to eq('nl')
    end

    it 'demonstrates inheritance chain works with existing fixtures' do
      expect(root_dataset.geo_id).to eq('nl')
      expect(child_dataset.geo_id).to eq('test1_ameland')
      expect(grandchild_dataset.geo_id).to eq('urk')

      expect(grandchild_dataset.parent).to eq(child_dataset.geo_id)
      expect(child_dataset.parent).to eq(root_dataset.geo_id)
    end
  end
end
