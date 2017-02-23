require 'rails_helper'

describe DatasetsController do
  it 'fetches the index page' do
    get :index

    expect(response).to redirect_to(new_user_session_path)
  end

  describe "when signed in" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:sign_in_user) { sign_in(user) }

    it 'fetches the show page' do
      dataset = Atlas::Dataset::Derived.find(:ameland)

      get :show, params: { area: dataset.area }

      expect(response).to be_success
    end

    describe 'redirects to root page when a dataset is not found' do
      before do
        get :show, params: { area: "does-not-exist" }
      end

      it 'redirects' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets flash message' do
        expect(flash[:error]).to be_present
      end
    end
  end
end
