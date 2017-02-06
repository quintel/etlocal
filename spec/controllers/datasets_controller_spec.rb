require 'rails_helper'

describe DatasetsController do
  it 'fetches the index page' do
    get :index

    expect(response).to be_success
  end

  it 'fetches the show page' do
    dataset = Dataset.create!(title: "ameland")

    get :show, params: { id: dataset.id }

    expect(response).to be_success
  end

  it 'fetches the edit page' do
    dataset = Dataset.create!(title: "ameland")

    get :edit, params: { id: dataset.id }

    expect(response).to be_success
  end

  describe "#update" do
    let(:dataset) { Dataset.create!(title: "ameland") }

    it 'can upload an xlsx file' do
      put :update, params: {
        id: dataset.id, dataset: {
          dataset_file: fixture_file_upload("test.xlsx"),
          commit_message: "Updating xlsx file"
        }
      }

      expect(dataset.reload.dataset_file.original_filename).to eq("test.xlsx")
    end

    it 'can upload an xls file' do
      put :update, params: {
        id: dataset.id,
        dataset: {
          dataset_file: fixture_file_upload("test.xls"),
          commit_message: "Updating xls file"
        }
      }

      expect(dataset.reload.dataset_file.original_filename).to eq("test.xls")
    end

    it 'can change the title of the dataset' do
      put :update, params: {
        id: dataset.id,
        dataset: {
          title: "non-ameland",
          commit_message: "Changing title"
        }
      }

      expect(dataset.reload.title).to eq("non-ameland")
    end

    it 'creates a version in the database' do
      put :update, params: {
        id: dataset.id,
        dataset: {
          title: "non-ameland",
          commit_message: "Changing title"
        }
      }

      expect(dataset.reload.versions.count).to eq(1)
    end
  end

  it 'can download the xls file'

  it 'can create a dataset'
end
