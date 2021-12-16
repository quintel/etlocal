require 'rails_helper'

dataset_inputs = Etsource.dataset_inputs.uniq
transformers   = Etsource.transformers

RSpec.describe "ETLocal's interface", :if => dataset_inputs.any?, type: :interface do
  # Validates DATASET_INPUT's used in sparse graph query upon their existence
  # in ETLocal.
  #
  dataset_inputs.each do |input|
    it "includes the DATASET_INPUT #{input}" do
      expect(InterfaceElement.items.detect do |item|
        item.key.to_s == input
      end).to_not be_nil
    end
  end

  InterfaceElement.items.each do |item|
    next if item.skip_validation

    if item.key =~ /^input/
      it "is included in a TQL #{item.key}" do
        expect(dataset_inputs).to include(item.key.to_s)
      end
    else
      it "#{item.key} is included in one-to-one transformer or is an area attribute" do
        expect(
          transformers.keys +
          Atlas::Dataset::Derived.attribute_set.map(&:name)
        ).to include(item.key)
      end
    end
  end

  # Validates if there's a key available that can set something in the
  # sparse graph. Skip attributes that have a sparse graph query attached.
  #
  transformers.each do |key, attribute|
    if attribute.respond_to?('sparse_graph_query') && attribute['sparse_graph_query'].blank?
      it "has a present sparse graph key for #{ key }" do
        expect(InterfaceElement.items.detect do |item|
          item.key == key.to_sym
        end).to_not be_nil
      end
    end
  end
end
