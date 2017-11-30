require 'rails_helper'

describe DatasetEditForm do
  let(:dataset) { FactoryGirl.create(:dataset) }

  it "is invalid" do
    commit_form = DatasetEditForm.new

    expect(commit_form.valid?).to eq(false)
  end

  it 'has all the attributes of the transformer dataset cast' do
    commit_form = DatasetEditForm.new(
      number_of_residences: 50
    )

    expect(commit_form.valid?).to eq(true)
  end

  context "submitting" do
    let(:commit_form) {
      DatasetEditForm.new(number_of_residences: 20)
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
