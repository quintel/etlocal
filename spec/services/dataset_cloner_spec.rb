require 'rails_helper'

RSpec.describe DatasetCloner do
  describe "cloning a public dataset" do
    let(:dataset) { FactoryGirl.create(:dataset) }
    let(:user)    { FactoryGirl.create(:user) }
    let!(:commit) { FactoryGirl.create(:initial_commit, dataset: dataset) }

    before { DatasetCloner.clone!(dataset, user) }

    it "clones a dataset" do
      expect(Dataset.count).to eq(2)
    end

    it "should be private" do
      expect(Dataset.last.public).to eq(false)
    end

    it "attaches the dataset to a user" do
      expect(Dataset.last.user).to eq(user)
    end

    it "duplicates the commits" do
      expect(Dataset.last.commits.count).to eq(1)
      expect(Commit.count).to eq(2)
    end

    it "duplicates the commits and dataset edits related" do
      commit = Dataset.last.commits.last

      expect(commit.dataset_edits.count).to eq(1)
    end
  end
end
