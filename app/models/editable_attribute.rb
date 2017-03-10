class EditableAttribute
  attr_reader :key

  def initialize(dataset, key, options = {})
    @dataset = dataset
    @key     = key
    @options = options
  end

  def unit
    @options['unit']
  end

  def group
    @options['group']
  end

  # If a dataset has an edit - give that value. If it doesn't have an edit,
  # fall back to the default value.
  def value
    @dataset.dataset_edits.value_for(@key) || @dataset.public_send(@key)
  end
end
