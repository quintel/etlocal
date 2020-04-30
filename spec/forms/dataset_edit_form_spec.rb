require 'rails_helper'

describe DatasetEditForm do
  let(:dataset) { FactoryBot.create(:dataset) }

  context "invalid" do
    it "empty form" do
      commit_form = DatasetEditForm.new

      expect(commit_form.valid?).to eq(false)
    end

    it "has a negative number of residences" do
      commit_form = DatasetEditForm.new(
        number_of_residences: -1,
        country: 'nl'
      )

      expect(commit_form.valid?).to eq(false)
    end

    it "number of residences is 0" do
      commit_form = DatasetEditForm.new(
        number_of_residences: 0,
        country: 'nl'
      )

      expect(commit_form.valid?).to eq(false)
    end

    it "has no country set" do
      commit_form = DatasetEditForm.new(
        number_of_residences: 1
      )

      expect(commit_form.valid?).to eq(false)
    end
  end

  it 'has all the attributes of the transformer dataset cast' do
    commit_form = DatasetEditForm.new(
      number_of_residences: 50,
      country: 'nl'
    )

    expect(commit_form.valid?).to eq(true)
  end

  context "submitting" do
    let(:commit_form) {
      DatasetEditForm.new(number_of_residences: 20, country: 'nl')
    }

    it "build a dataset edit for commit" do
      commit_form.submit(dataset)

      expect(dataset.commits.length).to eq(1)
    end

    it "builds edits for that commit" do
      commit_form.submit(dataset)

      expect(dataset.commits.last.dataset_edits.length).to eq(1)
    end
  end
end
