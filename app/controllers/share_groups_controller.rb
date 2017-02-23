class ShareGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_dataset

  def edit
    @share_group = ShareGroup.new(params[:share_group]).build
  end

  def update
    @share_group = ShareGroup.new(params[:share_group])

    if @share_group.save
      redirect_to dataset_path(@dataset.area), flash: {
        success: "Succesfully updated share group"
      }
    else
      render :edit
    end
  end
end
