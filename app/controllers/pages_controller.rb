class PagesController < ApplicationController
  layout false, only: :introduction

  def introduction
    respond_to do |format|
      format.js
    end
  end

  def set_new_locale
    set_locale

    session[:locale] = I18n.locale

    redirect_to root_path
  end
end
