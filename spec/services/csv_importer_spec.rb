require 'rails_helper'

RSpec.describe CSVImporter do
  let(:data_csv) do
    Tempfile.new('data.csv').tap do |file|
      file.puts(data)
      file.rewind
    end
  end

  let(:commits_yml) do
    Tempfile.new('commits.csv').tap do |file|
      file.puts(commits)
      file.rewind
    end
  end

  let(:importer) { described_class.new(data_csv.path, commits_yml.path) }

  before do
    # Datasets must exist first in order to import new data.
    CSV.parse(data, headers: true).each do |row|
      dataset = FactoryGirl.create(
        :dataset,
        geo_id: row['geo_id'] || 'ZZ0001',
        user: User.robot
      )

      FactoryGirl.create(:initial_commit, dataset: dataset)
    end
  end

  after do
    data_csv.path && data_csv.unlink
    commits_yml.path && commits_yml.unlink
  end

  context 'with a valid single edit/single commit' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_residences
          message:
            Because 5 is a magic number
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_residences
        GM0340,5
      CSV
    end

    it 'returns one commit' do
      expect(importer.run).to eq(Commit.last(1))
    end

    it 'creates one new commit' do
      expect { importer.run }.to change(Commit, :count).by(1)
    end

    it 'creates one new dataset edit' do
      expect { importer.run }.to change(DatasetEdit, :count).by(1)
    end

    it 'assigns the commit message' do
      importer.run
      expect(Commit.last.message).to eq('Because 5 is a magic number')
    end

    it 'assigns the dataset edit key' do
      importer.run
      expect(DatasetEdit.last.key).to eq('number_of_residences')
    end

    it 'assigns the dataset edit value' do
      importer.run
      expect(DatasetEdit.last.value).to eq(5)
    end

    context 'with a region name' do
      let(:commits) do
        <<~YAML
          ---
          - fields:
            - number_of_residences
            message:
              Because 5 is a magic number
        YAML
      end

      let(:data) do
        <<~CSV
          geo_id,name,number_of_residences
          GM0340,My First Area,5
        CSV
      end

      it 'changes the region name' do
        dataset = Dataset.find_by_geo_id('GM0340')

        expect { importer.run }
          .to(change { dataset.reload.name }.to('My First Area'))
      end
    end

    context 'with a blank name' do
      let(:commits) do
        <<~YAML
          ---
          - fields:
            - number_of_residences
            message:
              Because 5 is a magic number
        YAML
      end

      let(:data) do
        <<~CSV
          geo_id,name,number_of_residences
          GM0340,,5
        CSV
      end

      it 'does not change the dataset name' do
        dataset = Dataset.find_by_geo_id('GM0340')
        expect { importer.run }.not_to(change { dataset.reload.name })
      end
    end

    context 'with create_missing_datasets: true' do
      let(:importer) do
        described_class.new(
          data_csv.path,
          commits_yml.path,
          create_missing_datasets: true
        )
      end

      let(:commits) do
        <<~YAML
          ---
          - fields:
            - number_of_residences
            message:
              Because 5 is a magic number
        YAML
      end

      let(:data) do
        <<~CSV
          geo_id,name,number_of_residences
          GM0340,My First Area,5
        CSV
      end

      it 'changes the dataset name' do
        importer.run

        expect(Dataset.find_by_geo_id('GM0340').name).to eq('My First Area')
      end

      it 'creates one new commit' do
        expect { importer.run }.to change(Commit, :count).by(1)
      end

      it 'does not create a new dataset' do
        expect { importer.run }.not_to change(Dataset, :count)
      end
    end
  end

  context 'with a valid double edit/single commit' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_residences
          - number_of_inhabitants
          message:
            Because 5 is a magic number
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_residences,number_of_inhabitants
        GM0340,5,10
      CSV
    end

    it 'returns one commit' do
      expect(importer.run).to eq(Commit.last(1))
    end

    it 'creates one new commit' do
      expect { importer.run }.to change(Commit, :count).by(1)
    end

    it 'creates two new dataset edits' do
      expect { importer.run }.to change(DatasetEdit, :count).by(2)
    end

    it 'assigns the first dataset edit key' do
      commit = importer.run.first
      expect(commit.dataset_edits.first.key).to eq('number_of_residences')
    end

    it 'assigns the first dataset edit value' do
      commit = importer.run.first
      expect(commit.dataset_edits.first.value).to eq(5)
    end

    it 'assigns the second dataset edit key' do
      commit = importer.run.first
      expect(commit.dataset_edits.last.key).to eq('number_of_inhabitants')
    end

    it 'assigns the second dataset edit value' do
      commit = importer.run.first
      expect(commit.dataset_edits.last.value).to eq(10)
    end
  end

  context 'with a valid single edit/double commit' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_residences
          message:
            Because 5 is a magic number
        - fields:
          - number_of_inhabitants
          message:
            Because 10 is a magic number
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_residences,number_of_inhabitants
        GM0340,5,10
      CSV
    end

    it 'returns two commits' do
      expect(importer.run).to eq(Commit.last(2))
    end

    it 'creates two new commits' do
      expect { importer.run }.to change(Commit, :count).by(2)
    end

    it 'creates two new dataset edits' do
      expect { importer.run }.to change(DatasetEdit, :count).by(2)
    end

    it 'assigns the first dataset edit key' do
      commit = importer.run.first
      expect(commit.dataset_edits.first.key).to eq('number_of_residences')
    end

    it 'assigns the first dataset edit value' do
      commit = importer.run.first
      expect(commit.dataset_edits.first.value).to eq(5)
    end

    it 'assigns the second dataset edit key' do
      commit = importer.run.last
      expect(commit.dataset_edits.first.key).to eq('number_of_inhabitants')
    end

    it 'assigns the second dataset edit value' do
      commit = importer.run.last
      expect(commit.dataset_edits.first.value).to eq(10)
    end
  end

  context 'with a valid single edit/single commit, two data rows' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_residences
          message:
            Because 5 is a magic number
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_residences
        GM0340,5
        GM0341,10
      CSV
    end

    it 'returns two commits' do
      expect(importer.run).to eq(Commit.last(2))
    end

    it 'creates two new commits' do
      expect { importer.run }.to change(Commit, :count).by(2)
    end

    it 'creates two new dataset edits' do
      expect { importer.run }.to change(DatasetEdit, :count).by(2)
    end

    it 'assigns the dataset for the first dataset commit' do
      commit = importer.run.first
      expect(commit.dataset).to eq(Dataset.find_by_geo_id('GM0340'))
    end

    it 'assigns the dataset for the second dataset commit' do
      commit = importer.run.last
      expect(commit.dataset).to eq(Dataset.find_by_geo_id('GM0341'))
    end
  end

  context 'with a valid glob edit/single commit' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - :all
          message:
            Because 5 is a magic number
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_residences,number_of_inhabitants
        GM0340,5,10
      CSV
    end

    it 'creates one new commit' do
      expect { importer.run }.to change(Commit, :count).by(1)
    end

    it 'creates two new dataset edits' do
      expect { importer.run }.to change(DatasetEdit, :count).by(2)
    end

    it 'assigns the first dataset edit key' do
      commit = importer.run.first
      expect(commit.dataset_edits.first.key).to eq('number_of_residences')
    end

    it 'assigns the second dataset edit key' do
      commit = importer.run.first
      expect(commit.dataset_edits.last.key).to eq('number_of_inhabitants')
    end
  end

  context 'with a glob edit/two commits' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - :all
          message:
            Because 5 is a magic number
        - fields:
          - number_of_residences
          message:
            Because 5 is a magic number
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_residences,number_of_inhabitants
        GM0340,5,10
      CSV
    end

    it 'raises an error' do
      expect { importer.run }
        .to raise_error(/attributes specified in multiple commits/)
    end
  end

  context 'when the commit contains an illegal attribute' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - nope
          message:
            Because 5 is a magic number
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,nope
        GM0340,1
      CSV
    end

    it 'raises an error' do
      expect { importer.run }.to raise_error(/contains unknown fields/i)
    end
  end

  context 'when the commit contains an attribute missing from the data' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_residents
          - number_of_inhabitants
          message:
            Because 5 is a magic number
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_residents
        GM0340,5.0
      CSV
    end

    it 'raises an error' do
      expect { importer.run }
        .to raise_error(/contains fields which aren't present in the data/i)
    end
  end

  context 'when the commit is missing a message' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_inhabitants
          message:
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_inhabitants
        GM0340,10
      CSV
    end

    it 'raises an error' do
      expect { importer.run }
        .to raise_error(/one or more commits are missing a message/i)
    end
  end

  context 'with commits that have duplicate fields' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_inhabitants
          message:
            Commit 1
        - fields:
          - number_of_inhabitants
          message:
            Commit 2
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_inhabitants
        GM0340,10
      CSV
    end

    it 'raises an error' do
      expect { importer.run }
        .to raise_error(/attributes specified in multiple commits/i)
    end
  end

  context 'with a blank value' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_inhabitants
          message:
            My commit
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_inhabitants
        GM0340,
      CSV
    end

    it 'does not create a commit' do
      expect { importer.run }.not_to change(Commit, :count)
    end

    it 'does not create a dataset edit' do
      expect { importer.run }.not_to change(DatasetEdit, :count)
    end
  end

  context 'when the values are not changed' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_residences
          message:
            My commit
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_residences
        GM0340,1.0
      CSV
    end

    it 'does not create a commit' do
      expect { importer.run }.not_to change(Commit, :count)
    end

    it 'does not create a dataset edit' do
      expect { importer.run }.not_to change(DatasetEdit, :count)
    end
  end

  context 'when the CSV contains extra fields' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_residences
          message:
            My commit
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_residences,number_of_inhabitants
        GM0340,1.3,2.0
      CSV
    end

    it 'raises an error' do
      expect { importer.run }
        .to raise_error(/contains fields not used by any commit/i)
    end
  end

  context 'when the data file is missing' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_residences
          message:
            My commit
      YAML
    end

    let(:data) { '' }

    before { data_csv.unlink }

    it 'raises an error' do
      expect { importer.run }.to raise_error(/does not exist/i)
    end
  end

  context 'when the commit file is missing' do
    let(:commits) { '' }

    let(:data) do
      <<~CSV
        geo_id,number_of_residences
        GM0340,5
      CSV
    end

    before { commits_yml.unlink }

    it 'raises an error' do
      expect { importer.run }.to raise_error(/does not exist/i)
    end
  end

  context 'when the geo_id is missing from the data' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_inhabitants
          message:
            Because 5 is a magic number
      YAML
    end

    let(:data) do
      <<~CSV
        number_of_inhabitants
        5
      CSV
    end

    it 'raises an error' do
      expect { importer.run }.to raise_error(/is missing mandatory headers/i)
    end
  end

  context 'when the dataset is missing' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_inhabitants
          message:
            Because 5 is a magic number
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_inhabitants
        GM0340,5
      CSV
    end

    before { Dataset.find_by_geo_id('GM0340').destroy! }

    it 'raises an error' do
      expect { importer.run }.to raise_error(/no dataset exists matching/i)
    end

    context 'with create_missing_datasets: true and no "name" in the CSV' do
      let(:importer) do
        described_class.new(
          data_csv.path,
          commits_yml.path,
          create_missing_datasets: true
        )
      end

      it 'raises an error' do
        expect { importer.run }
          .to raise_error(/is missing mandatory headers: "name"/i)
      end
    end

    context 'with create_missing_datasets: true and a blank "name" in the CSV' do
      let(:importer) do
        described_class.new(
          data_csv.path,
          commits_yml.path,
          create_missing_datasets: true
        )
      end

      let(:data) do
        <<~CSV
          geo_id,name,number_of_inhabitants
          GM0340,,5
        CSV
      end

      it 'raises an error' do
        expect { importer.run }.to raise_error(/Name can't be blank/i)
      end
    end

    context 'with create_missing_datasets: true and an "name" in the CSV' do
      let(:importer) do
        described_class.new(
          data_csv.path,
          commits_yml.path,
          create_missing_datasets: true
        )
      end

      let(:data) do
        <<~CSV
          geo_id,name,number_of_inhabitants
          GM0340,My First Area,5
        CSV
      end

      it 'creates a new dataset' do
        expect { importer.run }.to change(Dataset, :count).by(1)
      end

      it 'sets the dataset name' do
        importer.run

        dataset = Dataset.find_by_geo_id('GM0340')
        expect(dataset.name).to eq('My First Area')
      end

      it 'sets the new area to belong to the robot' do
        importer.run

        dataset = Dataset.find_by_geo_id('GM0340')
        expect(dataset.user).to eq(User.robot)
      end
    end
  end

  context 'when there are no data rows to import' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_inhabitants
          message:
            Because 5 is a magic number
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_inhabitants
      CSV
    end

    it 'raises an error' do
      expect { importer.run }.to raise_error(/has no data to import/i)
    end
  end

  context 'with a valid single edit/single commit and a block' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_residences
          message:
            Because 5 is a magic number
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_residences
        GM0340,5
      CSV
    end

    it 'returns one commit' do
      commits = importer.run { |_, runner| runner.call }
      expect(commits).to eq(Commit.last(1))
    end
  end

  context 'with a valid single edit/single commit using the class method' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_residences
          message:
            Because 5 is a magic number
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,number_of_residences
        GM0340,5
      CSV
    end

    let(:result) { described_class.run(data_csv.path, commits_yml.path) }

    it 'returns one commit' do
      expect(result).to eq(Commit.last(1))
    end
  end

  context 'with a new dataset, create_missing_datasets, using the class method' do
    let(:commits) do
      <<~YAML
        ---
        - fields:
          - number_of_residences
          message:
            Because 5 is a magic number
      YAML
    end

    let(:data) do
      <<~CSV
        geo_id,name,number_of_residences
        GM0340,ABC,5
      CSV
    end

    let(:result) do
      described_class.run(
        data_csv.path,
        commits_yml.path,
        create_missing_datasets: true
      )
    end

    before { Dataset.find_by_geo_id('GM0340').destroy! }

    it 'returns one commit' do
      expect(result).to eq(Commit.last(1))
    end

    it 'creates a new dataset' do
      expect { result }.to change(Dataset, :count).by(1)
    end
  end
end
