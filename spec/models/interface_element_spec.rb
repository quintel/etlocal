require 'rails_helper'

RSpec.describe InterfaceElement do
  # Switch Atlas to the real Atlas
  before :all do
    Atlas.data_dir = Rails.configuration.etsource_path
  end

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

  after :all do
    Atlas.data_dir = "#{ ::Rails.root }/spec/fixtures/etsource"
  end
end
