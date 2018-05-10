require 'rails_helper'

RSpec.describe Sandbox do
  let(:dataset) { FactoryGirl.create(:dataset) }
  let(:sandbox) { Sandbox.new(dataset) }

  it 'may not execute queries outside of a run block' do
    expect { sandbox.execute('SUM(1, 2)') }
      .to raise_error(/cannot execute sandbox query/i)
  end

  context 'executing a valid query inside a run block' do
    it 'runs the query' do
      sandbox.run do |sb|
        expect(sb.execute('SUM(1, 2, 3)')).to eq(6)
      end
    end

    it 'returns the value of the final expression' do
      expect(sandbox.run { |sb| sb.execute('SUM(1, 2, 3)')}).to eq(6)
    end

    it 'runs multiple expressions' do
      sandbox.run do |sb|
        expect(sb.execute('SUM(1, 2, 3)')).to eq(6)
        expect(sb.execute('SUM(1, 2, 3, 4)')).to eq(10)
      end
    end

    it 'permits multiple run block' do
      expect(sandbox.run { |sb| sb.execute('SUM(1, 2, 3)')}).to eq(6)
      expect(sandbox.run { |sb| sb.execute('SUM(1, 2, 3, 4)')}).to eq(10)
    end

    it 'creates a temporary dataset' do
      sandbox.run do |_|
        expect(Atlas::Dataset.exists?(dataset.temp_name)).to be(true)
      end
    end

    it 'removes the temporary dataset after the block' do
      sandbox.run { |_| }
      expect(Atlas::Dataset.exists?(dataset.temp_name)).to be(false)
    end
  end

  context 'executing a query which raises an error' do
    it 'raises the error' do
      expect { sandbox.run { |sb| sb.execute('SUM(1') } }
        .to raise_error(Atlas::QueryError)
    end

    it 'removes the temporary dataset after the block' do
      begin
        sandbox.run { |sb| sb.execute('SUM(1') }
      rescue Atlas::QueryError
      end

      expect(Atlas::Dataset.exists?(dataset.temp_name)).to be(false)
    end
  end
end
