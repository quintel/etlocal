class BooleanDatasetEdit < DatasetEdit
  validates_inclusion_of :boolean_value, in: [true, false]
end
