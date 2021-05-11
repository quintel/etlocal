# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InterfaceElement do
  described_class.all.each do |interface_element|
    it "#{interface_element.key} is valid" do
      expect(interface_element).to be_valid
    end

    interface_element.groups.each do |interface_group|
      it "#{interface_group} is a valid interface group" do
        expect(interface_group).to be_valid
      end

      interface_group.items.each do |interface_item|
        it "#{interface_item.key} is a valid interface item" do
          expect(interface_item).to be_valid
        end
      end
    end
  end
end
