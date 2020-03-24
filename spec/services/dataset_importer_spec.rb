require 'rails_helper'

describe DatasetImporter do
  let(:csv_fixture_dir) { "#{fixture_path}/seeds" }
  let(:dataset_importer) do
    described_class.new("#{fixture_path}/seeds", show_progress: false)
  end

  describe 'import new datasets' do
    it 'adds all datasets' do
      expect { dataset_importer.import }.to change(Dataset, :count).by(4)
    end
  end

  describe 'importing a dataset that already exists' do
    let(:user) { User.robot }

    let!(:dataset) do
      FactoryBot.create(:dataset, geo_id: 'BU22168000', user: user)
    end

    let!(:commit) do
      FactoryBot.create(
        :commit,
        user: user, dataset: dataset, message: 'Test'
      )
    end

    let!(:dataset_edit) do
      FactoryBot.create(
        :dataset_edit,
        commit: commit,
        key: 'residences_roof_surface_available_for_pv',
        value: '1.0'
      )
    end

    it 'imports 3 datasets' do
      expect { dataset_importer.import }.to change(Dataset, :count).by(3)
    end

    describe 'datasets owned by the Robot' do
      let(:user) { User.robot }

      it 'have old commits removed' do
        expect { dataset_importer.import }
          .to change { Commit.where(id: commit.id).count }
          .from(1).to(0)
      end

      it 'have old dataset edits removed' do
        expect { dataset_importer.import }
          .to change { DatasetEdit.where(id: dataset_edit.id).count }
          .from(1).to(0)
      end

      it 'sets the value of the existing dataset' do
        expect { dataset_importer.import }
          .to(change do
            Dataset.find(dataset.id).editable_attributes
              .edits_for('residences_roof_surface_available_for_pv')
              .last.value
          end.from(1.0).to(31.01))
      end
    end

    describe 'datasets owned by a non-Robot user' do
      let(:user) { FactoryBot.create(:user) }

      it 'keeps the old commit' do
        expect { dataset_importer.import }
          .not_to change { Commit.where(id: commit.id).count }
          .from(1)
      end

      it 'keeps the old edit' do
        expect { dataset_importer.import }
          .not_to change { DatasetEdit.where(id: dataset_edit.id).count }
          .from(1)
      end
    end
  end
end
