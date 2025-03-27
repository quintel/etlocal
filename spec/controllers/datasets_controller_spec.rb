require 'rails_helper'
require 'support/graph'

describe DatasetsController do
  describe "when signed in" do
    let(:user) { FactoryBot.create(:user) }
    let!(:sign_in_user) { sign_in(user) }

    describe "#index" do
      it 'fetches index page' do
        get :index

        expect(response).to be_successful
      end
    end

    describe "#edit" do
      let(:dataset) { FactoryBot.create(:dataset, geo_id: 'test_1', name: "Test") }

      before do
        allow(Dataset).to receive(:find).and_return(dataset)
        allow(controller).to receive(:policy_scope).with(Dataset).and_return(Dataset)
        allow(Dataset).to receive(:clones).with(dataset, user).and_return([])
      end

      context "with no freeze_date in session" do
        it "uses editable_attributes" do
          attrs = { "name" => "Test" }

          expect(dataset).to receive(:editable_attributes).and_return(attrs)
          expect(DatasetEditForm).to receive(:new).with(attrs).and_call_original

          get :edit, params: { id: dataset.id }, format: :js, xhr: true

          form = controller.instance_variable_get(:@dataset_edit_form)
          expect(form).to be_a(DatasetEditForm)
        end
      end

      context "with valid freeze_date in session" do
        before do
          session[:freeze_date] = 1.week.ago.iso8601
        end

        it "uses editable_attributes_before with parsed date" do
          freeze_time = session[:freeze_date]
          parsed_time = Time.zone.parse(freeze_time)
          attrs = { "name" => "Frozen" }

          expect(dataset).to receive(:editable_attributes_before).with(parsed_time).and_return(attrs)
          expect(DatasetEditForm).to receive(:new).with(attrs).and_call_original

          get :edit, params: { id: dataset.id }, format: :js, xhr: true

          form = controller.instance_variable_get(:@dataset_edit_form)
          expect(form).to be_a(DatasetEditForm)
        end
      end

      context "with invalid freeze_date in session" do
        before do
          session[:freeze_date] = 'not-a-date'
        end

        it "falls back to editable_attributes" do
          attrs = { "name" => "Fallback" }

          expect(dataset).to receive(:editable_attributes).and_return(attrs)
          expect(DatasetEditForm).to receive(:new).with(attrs).and_call_original

          get :edit, params: { id: dataset.id }, format: :js, xhr: true

          form = controller.instance_variable_get(:@dataset_edit_form)
          expect(form).to be_a(DatasetEditForm)
        end
      end

      it "assigns @dataset_clones using policy_scope" do
        expect(controller).to receive(:policy_scope).with(Dataset).and_return(Dataset)
        expect(Dataset).to receive(:clones).with(dataset, user).and_return(["clone_1"])

        get :edit, params: { id: dataset.id }, format: :js, xhr: true

        clones = controller.instance_variable_get(:@dataset_clones)
        expect(clones).to eq(["clone_1"])
      end
    end

    describe "#show" do
      let(:dataset) { FactoryBot.create(:dataset, geo_id: 'test_1', name: "Test") }

      it "visits show" do
        get :show, params: { id: dataset.id }, format: :json, xhr: true

        expect(response).to be_successful
      end
    end

    describe '#download' do
      let(:user) { FactoryBot.create(:user) }
      let(:dataset) { FactoryBot.create(:dataset,
                                         geo_id: 'test_1',
                                         name: "Test",
                                         user: user) }

      describe "insufficient data for an analyzes" do
        it 'downloads the dataset as a zip file'
      end

      describe "succesfully" do
        let!(:commit) {
          FactoryBot.create(:initial_commit, dataset: dataset)
        }

        it 'downloads the dataset as a zip file'
      end
    end

    describe "#clone" do
      let(:user) { FactoryBot.create(:user) }

      def clone_dataset
        post :clone, params: { dataset_id: dataset.id, format: 'js' }
      end

      describe "clones the dataset - when public" do
        let(:dataset) { FactoryBot.create(:dataset,
                                           geo_id: 'test_1',
                                           name: "Test",
                                           user: user,
                                           public: true) }

        it "counts datasets to 2" do
          clone_dataset

          expect(Dataset.count).to eq(2)
        end
      end

      describe "can clone the dataset - when private - and the user's" do
        let(:dataset) { FactoryBot.create(:dataset,
                                           geo_id: 'test_1',
                                           name: "Test",
                                           user: user,
                                           public: false) }

        it "counts datasets to 1" do
          clone_dataset

          expect(Dataset.count).to eq(2)
        end
      end

      describe "can't clone the dataset - when private - and not the user's" do
        let(:dataset) { FactoryBot.create(:dataset,
                                           geo_id: 'test_1',
                                           name: "Test",
                                           user: FactoryBot.create(:user),
                                           public: false) }

        it "counts datasets to 1" do
          expect { clone_dataset }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end
  end

  context 'when the browser prefers English' do
    before do
      request.env['HTTP_ACCEPT_LANGUAGE'] = 'en'
      get :index
    end

    after { I18n.locale = I18n.default_locale }

    it 'loads in the EN locale' do
      expect(I18n.locale).to eq(:en)
    end
  end

  context 'when the browser prefers Dutch' do
    before do
      request.env['HTTP_ACCEPT_LANGUAGE'] = 'nl'
      get :index
    end

    after { I18n.locale = I18n.default_locale }

    it 'loads in the EN locale' do
      expect(I18n.locale).to eq(:nl)
    end
  end

  context 'when the browser prefers German' do
    before do
      request.env['HTTP_ACCEPT_LANGUAGE'] = 'de'
      get :index
    end

    after { I18n.locale = I18n.default_locale }

    it 'loads in the EN locale' do
      expect(I18n.locale).to eq(:en)
    end
  end

  describe '#git_file_info' do
    let(:dataset) { FactoryBot.create(:dataset, geo_id: 'test1', name: 'ameland') }

    context 'when the dataset does not exist' do
      let(:response) do
        get :git_file_info, params: {
          id: 'invalid',
          interface_element_key: 'nope',
          file_key: 'also/nope.csv'
        }
      end

      it 'returns 404 Not Found' do
        expect { response }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Dataset/)
      end
    end

    context 'when the interface element does not exist' do
      let(:response) do
        get :git_file_info, params: {
          id: dataset.geo_id,
          interface_element_key: 'nope',
          file_key: 'also/nope.csv'
        }
      end

      it 'returns 404 Not Found' do
        expect { response }
          .to raise_error(ActiveRecord::RecordNotFound, /Couldn't find InterfaceElement/)
      end
    end

    context 'when the interface element has no groups with paths' do
      before do
        allow(InterfaceElement).to receive(:find).with('test_element').and_return(
          InterfaceElement.new(groups: [InterfaceGroup.new])
        )
      end

      let(:response) do
        get :git_file_info, params: {
          id: dataset.geo_id,
          interface_element_key: 'test_element',
          file_key: 'also/nope.csv'
        }
      end

      it 'returns 404 Not Found' do
        expect { response }
          .to raise_error(ActiveRecord::RecordNotFound, "Couldn't find file")
      end
    end

    context 'when the file does not exist in the list of allowed files' do
      before do
        allow(InterfaceElement).to receive(:find).with('test_element').and_return(
          InterfaceElement.new(groups: [
            InterfaceGroup.new(
              type: :files,
              paths: ['this/is/fine.csv', 'also/yes.csv']
            )
          ])
        )
      end

      let(:response) do
        get :git_file_info, params: {
          id: dataset.geo_id,
          interface_element_key: 'test_element',
          file_key: 'also/nope.csv'
        }
      end

      it 'returns 404 Not Found' do
        expect { response }
          .to raise_error(ActiveRecord::RecordNotFound, "Couldn't find file")
      end
    end

    context 'when the file exists' do
      before do
        allow(InterfaceElement).to receive(:find).with('test_element').and_return(
          InterfaceElement.new(groups: [
            InterfaceGroup.new(
              type: :files,
              paths: ['curves/a.csv', 'curves/b.csv']
            )
          ])
        )
      end

      let(:response) do
        get :git_file_info, params: {
          id: dataset.geo_id,
          interface_element_key: 'test_element',
          file_key: 'curves/a.csv'
        }
      end

      it 'returns 200 OK' do
        expect(response).to be_successful
      end
    end
  end
end
