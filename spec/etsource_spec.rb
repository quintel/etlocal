require 'rails_helper'

WebMock.allow_net_connect!

RSpec.describe 'ETLocal interface', :etsource => true do
  dataset_inputs = JSON.parse(
    RestClient.get("#{ ENV['ETLOCAL'] }/api/v1/etsource/sparse_graph_queries").body
  )

  transformers = JSON.parse(
    RestClient.get("#{ ENV['ETLOCAL'] }/api/v1/etsource/transformers").body
  )

  # Validates DATASET_INPUT's used in sparse graph query upon their existence
  # in ETLocal.
  #
  dataset_inputs.each do |input|
    it "has a present DATASET_INPUT for #{ input }" do
      expect(InterfaceElement.items.detect do |item|
        item.key == input
      end).to_not be_nil
    end
  end

  InterfaceElement.items.each do |item|
    it "includes #{ item.key }" do
      expect(dataset_inputs).to include(item.key)
    end
  end

  # Validates if there's a key available that can set something in the
  # sparse graph. Skip attributes that have a sparse graph query attached.
  #
  transformers.each do |key, attribute|
    if attribute['sparse_graph_query'].blank?
      it "has a present sparse graph query for #{ key }" do
        expect(InterfaceElement.items.detect do |item|
          item.key == key
        end).to_not be_nil
      end
    end
  end
end
