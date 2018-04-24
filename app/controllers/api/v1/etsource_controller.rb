class Api::V1::EtsourceController < ApplicationController
  format 'json'

  def sparse_graph_queries
    render json: Etsource.dataset_inputs
  end

  def transformers
    render json: Transformer::GraphMethods.all
  end
end
