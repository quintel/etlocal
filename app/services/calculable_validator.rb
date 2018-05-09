class CalculableValidator < ActiveModel::Validator
  def validate(record)
    calc_attrs = record.attributes.slice(
      *InterfaceElement.items.map(&:key)
    )

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
           Atlas::QueryError,
           ArgumentError => error
      record.errors.add(:calculation, error.message)
    end
  end
end
