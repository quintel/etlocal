class SandboxController < ApplicationController
  helper_method :dataset

  before_action :authenticate_user!
  before_action :authorize_user!

  # GET /datasets/:id/sandbox
  def index
    @query = ''
  end

  # POST /datasets/:id/sandbox
  def execute
    @query = query
    @result = Sandbox.new(dataset).run { |sandbox| sandbox.execute(@query) }

    render :index
  rescue StandardError => ex
    @error = ex
    render :index
  end

  private

  def query
    params.require(:query)
  end

  def dataset
    @dataset ||= Dataset.find(params[:dataset_id])
  end

  def authorize_user!
    authorize dataset, :sandbox?
  end
end
