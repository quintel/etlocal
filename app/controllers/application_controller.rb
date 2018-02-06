class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit({ roles: [] }, :name, :email, :password,
                         :password_confirmation)
    end
  end

  def find_dataset
    @dataset = Dataset.find(params[:id] || params[:dataset_id])

    unless @dataset
      flash[:error] = I18n.t('datasets.flash.not_found')

      redirect_to root_path
    end
  end
end
