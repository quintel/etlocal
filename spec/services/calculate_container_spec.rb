require 'rails_helper'
require 'support/graph'

RSpec.describe CalculateContainer do
  let(:dataset) { FactoryGirl.create(:dataset) }

  it "raises an error" do
    expect { CalculateContainer.new(dataset, {}) }.to raise_error(ArgumentError)
  end

  context "calculate" do
    let(:container) { CalculateContainer.new(dataset, dataset_params) }

    let(:dataset_params) {
      { 'number_of_residences' => 10 }
    }

    describe "refinery succeeds" do
      it "succesfully generates a dataset" do
        expect_any_instance_of(Atlas::Runner).to receive(:calculate)

        container.tryout!
      end
    end
  end
end
