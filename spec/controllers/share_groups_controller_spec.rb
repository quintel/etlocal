require 'rails_helper'

describe ShareGroupsController do
  let(:user) { FactoryGirl.create(:user) }
  let!(:sign_in_user) { sign_in(user) }
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }

  describe "#edit" do
    describe 'visits edit page of share groups controller' do
      before do
        get :edit, params: { dataset_area: 'ameland', share_group: 'cooling_buildings' }
      end

      it 'expects a success response' do
        expect(response).to be_success
      end

      it 'builds a share group' do
        expect(controller.instance_variable_get(:"@share_group")).to be_a(Array)
      end
    end

    describe 'visits a share group which does not exist' do
      before do
        get :edit, params: { dataset_area: 'ameland', share_group: 'does-not-exist' }
      end

      it 'redirects' do
        expect(response).to redirect_to(dataset_path(dataset.key))
      end

      it 'flashes' do
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "#update" do
    it 'updates a share group' do
    end
  end
end
