# frozen_string_literal: true

require 'rails_helper'

describe PagesController do
  describe '#introduction' do
    it 'visits the introduction' do
      get :intro
      expect(response).to be_successful
    end
  end

  describe '#set_new_locale' do
    let(:set_new_locale) { put :set_new_locale, params: { locale: 'nl' } }

    context 'when no locale was set' do
      it 'reloads the page' do
        set_new_locale
        expect(response).to be_redirect
      end

      it 'sets the locale to nl' do
        set_new_locale
        expect(session[:locale]).to eq :nl
      end
    end

    context 'when the locale was already set to en' do
      before { session[:locale] = :en }

      it 'sets the locale to nl' do
        set_new_locale
        expect(session[:locale]).to eq :nl
      end
    end
  end
end
