class CalculableValidator < ActiveModel::Validator
  def validate(record)
    calc_attrs = record.attributes.slice(
      *InterfaceElement.items.map(&:key)
    )

    puts record.attributes.reject{ |a,v| v.nil?}

    begin
      dataset = Dataset.new(
        name: 'calculation_shell',
        country: record.attributes[:country]
      )

      CalculateContainer.new(
        calc_attrs.merge(
          area: dataset.temp_name,
          base_dataset: dataset.base_dataset
        )
      ).tryout!

    rescue Refinery::IncalculableGraphError,
           Refinery::FailedValidationError,
           Atlas::QueryError,
           Atlas::DocumentNotFoundError,
           ArgumentError => error
      record.errors.add(:calculation, error.message)
    end
  end
end
