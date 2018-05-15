require 'rails_helper'

RSpec.describe CSVImporter do
  describe '#import' do
    let!(:import) { CSVImporter.import!("#{fixture_path}/csvs/#{file}") }

    describe 'imports a csv with a single edit' do
      let(:file) { 'single_edit.csv' }

      it 'creates a single edit' do
        expect(DatasetEdit.count).to eq(1)
      end

      it 'creates a single commit' do
        expect(Commit.count).to eq(1)
      end

      it 'creates a single dataset' do
        expect(Dataset.count).to eq(1)
      end

      it 'validates connections' do
        expect(Dataset.first.commits.count).to eq(1)
      end
    end

    describe 'imports a csv with multiple edits' do
      let(:file) { 'multi_edit.csv' }

      it 'creates three edits' do
        expect(DatasetEdit.count).to eq(2)
      end

      it 'creates an edit per commit' do
        expect(Commit.count).to eq(2)
      end

      it 'creates a single dataset' do
        expect(Dataset.count).to eq(1)
      end

      it 'validates connections' do
        expect(Dataset.first.commits.count).to eq(2)
      end
    end
  end

  describe 'incorrect format' do
    let(:import) { CSVImporter.import!("#{fixture_path}/csvs/#{file}") }

    describe 'keys that do not exist' do
      let(:file) { 'mismatching_keys.csv' }

      it 'import raises an error' do
        expect { import }.to raise_error(ArgumentError)
      end
    end

    describe 'values that are blank' do
      let(:file) { 'blank_values.csv' }

      it 'import raises an error' do
        expect { import }.to raise_error(ArgumentError)
      end
    end

    describe 'missing documentation' do
      let(:file) { 'no_doc.csv' }

      it 'import raises an error' do
        expect { import }.to raise_error(ArgumentError)
      end
    end
  end
end
