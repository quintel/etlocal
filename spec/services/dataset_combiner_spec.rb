require 'rails_helper'

RSpec.describe DatasetCombiner do

  let(:dataset_1) { FactoryBot.create(:dataset) }
  let(:dataset_2) { FactoryBot.create(:dataset) }

  describe 'during initialization' do

    # We test the arguments quite extensively since the DatasetCombiner is a service class
    # that will be evoked from the command-line and thus can have more error-prone given arguments.
    describe 'when validating arguments' do

      it 'should raise an ArgumentError if mandatory arguments are ommitted' do
        expect do
          described_class.new(
            target_dataset_id: nil,
            source_data_year: nil,
            source_dataset_ids: nil,
            target_area_name: nil
          )
        end.to raise_error(
          ArgumentError,
          /Error! The following mandatory arguments were omitted:/
        )
      end

      it 'should check whether source_data_year is a valid year' do
        expect do
          described_class.new(
            target_dataset_id: 'PV20',
            source_data_year: 1,
            source_dataset_ids: [dataset_1.geo_id],
            target_area_name: 'Groningen'
          )
        end.to raise_error(
          ArgumentError,
          /Error! The source_data_year provided is not a valid year/
        )

        expect do
          described_class.new(
            target_dataset_id: 'PV20',
            source_data_year: 2000,
            source_dataset_ids: [dataset_1.geo_id],
            target_area_name: 'Groningen'
          )
        end.not_to raise_error(ArgumentError)
      end

      it 'should check whether source_dataset_ids is one-dimensional array' do
        expect do
          described_class.new(
            target_dataset_id: 'PV20',
            source_data_year: 2000,
            source_dataset_ids: { a: 1, b: 2 },
            target_area_name: 'Groningen'
          )
        end.to raise_error(
          ArgumentError,
          /Error! The source_dataset_ids should be a set of ids/
        )

        expect do
          described_class.new(
            target_dataset_id: 'PV20',
            source_data_year: 2000,
            source_dataset_ids: [[1], [2]],
            target_area_name: 'Groningen'
          )
        end.to raise_error(
          ArgumentError,
          /Error! The source_dataset_ids should be a set of ids/
        )

        expect do
          described_class.new(
            target_dataset_id: 'PV20',
            source_data_year: 2000,
            source_dataset_ids: [dataset_1.geo_id, dataset_2.geo_id],
            target_area_name: 'Groningen'
          )
        end.not_to raise_error(ArgumentError)

      end

    end

    describe 'when setting defaults' do

    end

  end # / during initialization

  describe 'when performing the data combination' do

    let(:combiner) do
      described_class.new(
        target_dataset_id: 'PV20',
        source_data_year: 2000,
        source_dataset_ids: [dataset_1.geo_id, dataset_2.geo_id],
        target_area_name: 'Groningen'
      )
    end

    context '#combine_datasets' do

      it 'should call the DatasetCombiner::ValueProcessor with the correct initialized datasets' do
        expect_any_instance_of(
          DatasetCombiner::ValueProcessor
        ).to receive(
          :perform
        ).with(
          [dataset_1, dataset_2]
        )

        combiner.combine_datasets
      end

    end

    context '#export_migrations' do

      it 'should call the DatasetCombiner::DataExporter with the correct attributes' do
        expect_any_instance_of(
          DatasetCombiner::DataExporter
        ).to receive(
          :perform
        ).with(
          target_dataset_id: 'PV20',
          target_area_name: 'Groningen',
          source_area_names: [dataset_1.name, dataset_2.name],
          combined_item_values: nil,
          migration_slug: '2000'
        )

        combiner.export_data
      end

    end

  end

end
