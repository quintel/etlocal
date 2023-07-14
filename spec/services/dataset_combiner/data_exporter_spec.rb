require 'rails_helper'

RSpec.describe DatasetCombiner::DataExporter do

  let(:target_geo_id) { 'PV20' }
  let(:target_area_name) { 'Groningen' }
  let(:migration_slug) { 'update_2020' }
  let(:combined_item_values) { { electricity: 1, water: 2, coal: 3, gas: 4} }
  let(:source_area_names) { ['Groningen', 'Haren', 'Hoogkerk', 'Ten Boer'] }
  let(:exporter) do
    described_class.new(
      target_dataset_geo_id: target_geo_id,
      target_area_name: target_area_name,
      migration_slug: migration_slug,
      combined_item_values: combined_item_values,
      source_area_names: source_area_names
    )
  end
  # Make a temporary directory for the exporter to work in
  # so we can properly test writing and reading files
  let(:tmpdir) { Pathname.new(Dir.mktmpdir) }

  before do
    # This will now be the base directory all other directories and filenames are based upon
    allow(exporter).to receive(:migrate_directory).and_return(tmpdir)
  end

  after do
    FileUtils.remove_dir(tmpdir)
  end

  describe 'when generating the migration' do
    it 'creates a file with the correct name and content' do
      expect(
        File.exist?(tmpdir.join(exporter.send(:migration_filename)))
      ).to be(false)

      exporter.send(:create_migration)

      migration_contents = File.open(tmpdir.join(exporter.send(:migration_filename))).to_a

      # Verify line 1 and 3 as those contain the dynamic contents
      expect(
        migration_contents[0].strip
      ).to eq(
        "class #{exporter.send(:migration_name).underscore.camelize} < ActiveRecord::Migration[5.0]"
      )
      expect(
        migration_contents[2].strip
      ).to eq(
        "directory    = Rails.root.join('db/migrate/#{exporter.send(:migration_filename)}')"
      )

      # Also verify the 'create_missing_datasets: true' argument was added to the CSVImporter line
      expect(
        migration_contents[15].strip
      ).to eq(
        'CSVImporter.run(data_path, commits_path, create_missing_datasets: true) do |row, runner|'
      )
    end

    it 'creates a migration directory with the correct name' do
      expect(
        Dir.exist?(exporter.send(:migration_directory))
      ).to be(false)

      exporter.send(:create_migration)

      expect(
        Dir.exist?(exporter.send(:migration_directory))
      ).to be(true)
    end
  end

  describe 'when generating the data file' do

    before do
      exporter.send(:migration_directory).mkdir
      exporter.send(:export_data_file)
    end

    it 'creates the file in the correct migration directory' do
      expect(
        File.exist?(
          tmpdir.join(exporter.send(:migration_directory).join(described_class::DATA_FILENAME))
        )
      ).to be(true)
    end

    it 'fills the data file in a CSV format with a header line and a data line' do
      csv_contents = File.open(
        tmpdir.join(exporter.send(:migration_directory).join(described_class::DATA_FILENAME))
      ).to_a

      # Check header contents on first line
      expect(csv_contents[0].strip).to eq(
        "name,geo_id,#{combined_item_values.keys.join(',')}"
      )

      # Check data contents on second line
      expect(csv_contents[1].strip).to eq(
        "#{target_area_name},#{target_geo_id},#{combined_item_values.values.join(',')}"
      )
    end
  end

  describe 'when generating the commits file' do

    before do
      exporter.send(:migration_directory).mkdir
      exporter.send(:export_commits_file)
    end

    it 'creates the file in the correct migration directory' do
      expect(
        File.exist?(
          tmpdir.join(exporter.send(:migration_directory).join(described_class::COMMITS_FILENAME))
        )
      ).to be(true)
    end

    it 'fills the commits file in a yml format a description containing the names of the combined areas' do
      expect(
        YAML.load_file(
          tmpdir.join(exporter.send(:migration_directory).join(described_class::COMMITS_FILENAME))
        )
      ).to eq(
        {
          fields: [:all],
          message: "Optelling van de volgende gebieden: #{source_area_names.join(', ')}"
        }
      )
    end
  end

end
