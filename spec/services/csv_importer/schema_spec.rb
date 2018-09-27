require 'rails_helper'

RSpec.describe CSVImporter::Schema do
  let(:schema) do
    described_class.new(provided_headers, name_required: name_required)
  end

  let(:name_required) { false }

  context 'with provided headers [a, b, c]' do
    let(:provided_headers) { %w[a b c] }

    context 'with name_required=false' do
      it 'has "geo_id" as a mandatory header' do
        expect(schema.mandatory_headers).to include('geo_id')
      end

      it 'does not have "name" as an mandatory header' do
        expect(schema.mandatory_headers).not_to include('name')
      end

      it 'has "name" as an optional header' do
        expect(schema.optional_headers).to include('name')
      end

      it 'has "a", "b", and "c" as changes' do
        expect(schema.changes).to eq(%w[a b c ])
      end
    end

    context 'with name_required=true' do
      let(:provided_headers) { %w[a b c] }
      let(:name_required) { true }

      it 'has "geo_id" as a mandatory header' do
        expect(schema.mandatory_headers).to include('geo_id')
      end

      it 'has "name" as n mandatory header' do
        expect(schema.mandatory_headers).to include('name')
      end

      it 'does not have "name" as an optional header' do
        expect(schema.optional_headers).not_to include('name')
      end

      it 'has "a", "b", and "c" as changes' do
        expect(schema.changes).to eq(%w[a b c ])
      end
    end
  end
end
