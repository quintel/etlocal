class PagesController < ApplicationController
  layout false, only: :introduction

  def intro
    render layout: 'map'
  end

  def set_new_locale
    set_locale

    session[:locale] = I18n.locale

    redirect_back fallback_location: root_path
  end
end
