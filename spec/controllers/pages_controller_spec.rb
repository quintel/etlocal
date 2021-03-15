# frozen_string_literal: true

require 'rails_helper'

describe PagesController do
  describe '#introduction' do
    it 'visits the introduction' do
      get :introduction, format: :js, xhr: true
      expect(response).to be_successful
    end
  end
end
