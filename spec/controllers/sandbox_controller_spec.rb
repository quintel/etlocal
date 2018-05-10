require 'rails_helper'

RSpec.describe SandboxController, type: :controller do
  describe '#index' do
    let(:dataset) { FactoryGirl.create(:dataset) }

    it 'redirects when not signed in' do
      get :index, params: { dataset_id: dataset.id }

      expect(response).to redirect_to(new_user_session_path)
    end

    describe "when signed in as a normal user" do
      let(:user) { FactoryGirl.create(:user) }
      let!(:sign_in_user) { sign_in(user) }

      it 'raises a NotAuthorizeError' do
        expect {
          get :index, params: { dataset_id: dataset.id }
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe "when signed in as a Quintel user" do
      let(:user) { FactoryGirl.create(:quintel_user) }
      let!(:sign_in_user) { sign_in(user) }

      it 'visits index' do
        get :index, params: { dataset_id: dataset.id }
        expect(response).to be_success
      end
    end
  end # index

  describe '#execute' do
    let(:dataset) { FactoryGirl.create(:dataset) }

    it 'redirects when not signed in' do
      get :execute, params: { dataset_id: dataset.id }

      expect(response).to redirect_to(new_user_session_path)
    end

    describe "when signed in as a normal user" do
      let(:user) { FactoryGirl.create(:user) }
      let!(:sign_in_user) { sign_in(user) }

      it 'raises a NotAuthorizeError' do
        expect {
          post :execute, params: { dataset_id: dataset.id }
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe "when signed in as a Quintel user" do
      let(:user) { FactoryGirl.create(:quintel_user) }
      let!(:sign_in_user) { sign_in(user) }

      render_views

      it 'visits index' do
        post :execute, params: { dataset_id: dataset.id }
        expect(response).to be_success
      end

      it 'executes a valid query' do
        post :execute, params: { dataset_id: dataset.id, query: 'SUM(1, 2)' }

        expect(response.body).to include('<pre class="result">3</pre>')
      end

      it 'describes the error given an invalid query' do
        post :execute, params: {
          dataset_id: dataset.id, query: 'AREA(no)'
        }

        expect(response.body).to include('<pre class="error">')
      end
    end
  end # execute
end
