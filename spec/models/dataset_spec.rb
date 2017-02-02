require 'rails_helper'

describe Dataset do
  it 'creates a dataset' do
    dataset = Dataset.new(title: "ameland")
    dataset.save

    expect(Dataset.count).to eq(1)
  end

  describe "committing" do
    it 'updates the title' do
      dataset = Dataset.create(title: "ameland")

      dataset.title = "ameland-edit"
      dataset.commit_message = "test"

      expect(dataset.save).to eq(true)
    end

    it "shouldn't update without a commit message" do
      dataset = Dataset.create(title: "ameland")

      dataset.title = "ameland-edit"

      expect(dataset.save).to eq(false)
    end
  end
end
