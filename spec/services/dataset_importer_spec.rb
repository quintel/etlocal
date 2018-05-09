require 'rails_helper'

describe DatasetImporter do
  before do
    csv = [fixture_path, 'nl_datasets.csv'].join('/')

    expect(dataset_importer).to receive(:datasets)
      .at_least(:once)
      .and_return(CSV.read(csv, headers: true))
  end

  let(:dataset_importer) { DatasetImporter.new }

  it "imports all datasets" do
    dataset_importer.import

    expect(Dataset.count).to eq(8)
  end

  describe "re-importing" do
    let!(:dataset) { FactoryGirl.create(:dataset, geo_id: 'BU16800000') }
    let!(:robot_commit) {
      FactoryGirl.create(:commit,
        user: User.robot, dataset: dataset, message: "Test")
    }

    # Brings the total to: 7 + 1
    it "imports 7 datasets" do
      dataset_importer.import

      expect(Dataset.count).to eq(8)
    end

    describe "with existing changes" do
      describe "doesn't change a value if it is changed by another user" do
        # Robot commit (that is always present)
        # New commit
        let(:commit) {
          FactoryGirl.create(:commit, dataset: dataset, message: "Test")
        }

        let!(:dataset_edit) {
          FactoryGirl.create(:dataset_edit, commit: commit,
            key: 'residences_roof_surface_available_for_pv', value: '1.0')
        }

        it "doesn't update value of the existing dataset" do
          dataset_importer.import

          expect(dataset_edit.reload.value).to eq(1.0)
        end
      end
    end
  end
end
