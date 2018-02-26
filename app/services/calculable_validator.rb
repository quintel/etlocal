class CalculableValidator < ActiveModel::Validator
  def validate(record)
    calc_attrs = record.attributes.slice(
      *EditableAttributesCollection.keys
    ).stringify_keys

    begin
      dataset = Dataset.new(area: 'calculation_shell')
      CalculateContainer.new(
        calc_attrs.merge(
          area: dataset.temp_name,
          base_dataset: dataset.country
        )
      ).tryout!

    rescue Refinery::IncalculableGraphError,
           Refinery::FailedValidationError,
           ArgumentError => error
      record.errors.add(:calculation, error)
    end
  end
end
