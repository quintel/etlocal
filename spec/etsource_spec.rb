require 'rails_helper'

WebMock.allow_net_connect!

def fetch_remote(suffix)
  JSON.parse(
    begin
      RestClient.get(
        "#{ Rails.configuration.etsource_export_root }/api/v1/etsource/#{ suffix }"
      ).body
    rescue RestClient::ExceptionWithResponse => e
      "[]"
    end
  )
end

RSpec.describe 'ETLocal interface', :etsource => true do
  # Validates DATASET_INPUT's used in sparse graph query upon their existence
  # in ETLocal.
  #
  fetch_remote('sparse_graph_queries').each do |input|
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
  fetch_remote('transformers').each do |key, attribute|
    if attribute['sparse_graph_query'].blank?
      it "has a present sparse graph query for #{ key }" do
        expect(InterfaceElement.items.detect do |item|
          item.key == key
        end).to_not be_nil
      end
    end
  end
end
