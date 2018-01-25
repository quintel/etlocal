class CalculableValidator < ActiveModel::Validator
  def validate(record)
    dataset    = Dataset.new(area: 'calculation_shell')
    calc_attrs = record.attributes.slice(
      *EditableAttributesCollection.keys
    ).stringify_keys

    begin
      CalculateContainer.new(dataset, calc_attrs).tryout!
    rescue Refinery::IncalculableGraphError,
           Refinery::FailedValidationError,
           ArgumentError => error
      record.errors.add(:calculation, error)
    end
  end
end
