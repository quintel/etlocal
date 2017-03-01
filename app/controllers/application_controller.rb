class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit({ roles: [] }, :name, :email, :password, :password_confirmation)
    end
  end

  def find_dataset
    @dataset = Dataset.find(params[:area] || params[:dataset_area])

    unless @dataset
      flash[:error] = I18n.t("datasets.flash.not_found", area: params[:area])

      redirect_to root_path
    end
  end
end
