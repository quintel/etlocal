# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GitFiles do
  context 'when globbing files without a parent dataset' do
    let(:dataset) { Atlas::Dataset.find(:nl) }
    let(:files) { described_class.glob(dataset, %w[curves/**/*.csv]) }

    it 'includes files in the top-level directory' do
      expected = Pathname.new('datasets/nl/curves/a.csv')
      expect(files.find { |f| f.git_path == expected }).not_to be_nil
    end

    it 'includes files in subdirectories' do
      expected = Pathname.new('datasets/nl/curves/weather/default/b.csv')
      expect(files.find { |f| f.git_path == expected }).not_to be_nil
    end
  end

  context 'with overlapping glob patterns' do
    let(:dataset) { Atlas::Dataset.find(:nl) }
    let(:files) { described_class.glob(dataset, %w[curves/**/*.csv curves/*.csv]) }

    it 'does not duplicate paths' do
      expected = Pathname.new('datasets/nl/curves/a.csv')
      expect(files.count { |f| f.git_path == expected }).to eq(1)
    end
  end

  context 'when globbing files with a parent dataset' do
    let(:dataset) { Atlas::Dataset.find(:test1_ameland) }
    let(:files) { described_class.glob(dataset, %w[curves/**/*.csv]) }

    it 'includes files from the parent dataset' do
      expected = Pathname.new('datasets/test1_ameland/curves/a.csv')
      expect(files.find { |f| f.git_path == expected }).not_to be_nil
    end

    it 'does not include overwritten files from the parent dataset' do
      expected = Pathname.new('datasets/nl/curves/a.csv')
      expect(files.find { |f| f.git_path == expected }).to be_nil
    end
  end

  context 'with a symlinked file to a parent' do
    let(:dataset) { Atlas::Dataset.find(:test1_ameland) }
    let(:files) { described_class.glob(dataset, %w[curves/symlink.csv]) }

    before do
      FileUtils.ln_s(
        dataset.parent.dataset_dir.join('curves/a.csv'),
        dataset.dataset_dir.join('curves/symlink.csv')
      )
    end

    after do
      dataset.dataset_dir.join('curves/symlink.csv').unlink
    end

    it 'resolves the path to the real file', :focus do
      expect(files.first.git_path).to eq(Pathname.new('datasets/nl/curves/a.csv'))
    end
  end

  context 'when globbing files with a parent, and the file is a symlink' do
    let(:dataset) { Atlas::Dataset.find(:test1_ameland) }
    let(:files) { described_class.glob(dataset, %w[curves/symlink.csv]) }

    before do
      FileUtils.ln_s(
        dataset.parent.dataset_dir.join('curves/a.csv'),
        dataset.parent.dataset_dir.join('curves/symlink.csv')
      )
    end

    after do
      dataset.parent.dataset_dir.join('curves/symlink.csv').unlink
    end

    it 'resolves the path to the real file', :focus do
      expect(files.first.git_path).to eq(Pathname.new('datasets/nl/curves/a.csv'))
    end
  end

  describe GitFiles::GitFile do
    let(:one) do
      described_class.new(Pathname.new('a/B/c.txt.gz'), Pathname.new('B/c.txt.gz'), false)
    end

    let(:two) do
      described_class.new(Pathname.new('a/B/d.txt'), Pathname.new('B/d.txt'), false)
    end

    it 'is sorted by the key' do
      expect([two, one].sort).to eq([one, two])
    end

    it 'defaults to no description' do
      expect(one.description).to be_nil
    end

    it 'has a sortable key using the downcased localised filenames' do
      expect(one.sortable_key).to eq(%w[b c])
    end

    it 'has a key based on the basename' do
      expect(one.basename_key).to eq('c')
    end

    it 'can retrieve a Git log for the file' do
      allow(Atlas).to receive(:data_dir).and_return(Rails.root)

      file = described_class.new(
        Rails.root.join('spec/fixtures/etsource/datasets/nl/nl.full.ad'),
        Pathname.new('nl.full.ad'),
        false
      )

      expect(file.log.to_a.length).to be_positive
    end

    it 'can retrieve an empty log when the file does not exist' do
      allow(Atlas).to receive(:data_dir).and_return(Rails.root)

      file = described_class.new(
        Rails.root.join('spec/fixtures/etsource/datasets/nl/nope.ad'),
        Pathname.new('nope.ad'),
        false
      )

      expect(file.log.to_a.length).to eq(0)
    end
  end
end
