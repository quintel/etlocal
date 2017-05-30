require 'rails_helper'

describe AttributeValidator do
  it "is invalid" do
    expect(AttributeValidator.valid?({})).to eq(false)
  end

  it "is valid" do
    mandatory_inputs = {
      "gas_consumption"                    => 5.0,
      "electricity_consumption"            => 5.0,
      "roof_surface_available_for_pv"      => 5.0,
      "number_of_inhabitants"              => 5.0,
      "number_of_residences_with_solar_pv" => 5.0,
      "percentage_of_old_residences"       => 10,
      "building_area"                      => 24
    }

    expect(AttributeValidator.valid?(mandatory_inputs)).to eq(true)
  end
end
