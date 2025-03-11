class PagesController < ApplicationController
  layout false, only: :introduction

  def introduction
    respond_to do |format|
      format.js
    end
  end

  # New small route to redirect version form to just like we do with locale
  # def set_new_version
  #   session[:freeze_date] = version logic (from Version model!)
  # end

  def set_new_locale
    set_locale

    session[:locale] = I18n.locale

    redirect_back fallback_location: root_path
  end
end
