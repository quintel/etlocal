class PagesController < ApplicationController
  def set_locale
    super

    session[:locale] = I18n.locale

    render(plain: '', status: :ok)
  end
end
