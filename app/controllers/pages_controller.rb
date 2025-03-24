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

    redirect_back fallback_location: root_path
  end

  def set_version
    version = Versions.find_by_name(params[:version])

    if version
      session[:freeze_date] = version['freeze_date']
      redirect_back fallback_location: root_path
    else
      redirect_back fallback_location: root_path, alert: 'Unknown version'
    end
  end
end
