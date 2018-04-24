require 'rails_helper'

RSpec.describe InterfaceElement do
  # Switch Atlas to the real Atlas
  old_data_dir = Atlas.data_dir
  Atlas.data_dir = Rails.configuration.etsource_path

  context 'testing if interface element' do
    InterfaceElement.all.each do |interface_element|
      it "#{ interface_element.key } is valid" do
        expect(interface_element).to be_valid
      end

      interface_element.groups.each do |interface_group|
        it "#{ interface_group } is a valid interface group" do
          expect(interface_group).to be_valid
        end

        interface_group.items.each do |interface_item|
          it "#{ interface_item.key } is a valid interface item" do
            expect(interface_item).to be_valid
          end
        end
      end
    end

    Etsource.dataset_inputs.each do |input|
      it "has a present DATASET_INPUT for #{ input }" do
        expect(InterfaceElement.items.detect do |item|
          item.key == input
        end).to_not be_nil
      end
    end

    Transformer::GraphMethods.all.each do |key, attribute|
      if attribute.sparse_graph_query.blank?
        it "has a present sparse graph query for #{ key }" do
          expect(InterfaceElement.items.detect do |item|
            item.key == key
          end).to_not be_nil
        end
      end
    end
  end

  Atlas.data_dir = old_data_dir
end
