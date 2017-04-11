require 'rails_helper'

describe DatasetsController do
  it 'fetches the index page' do
    get :index

    expect(response).to redirect_to(new_user_session_path)
  end

end
