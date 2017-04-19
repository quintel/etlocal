class EditableAttribute
  attr_reader :key

  def initialize(dataset, key, edits, options = {})
    @dataset = dataset
    @key     = key
    @edits   = edits
    @options = options
  end

  def unit
    @options['unit']
  end

  def group
    @options['group']
  end

  def default_value
    @options['default']
  end

  def previous
    @edits
  end

  def latest
    previous.first
  end

  def default
    if is_atlas_attribute?
      @dataset.atlas_dataset.public_send(@key)
    end
  end

  # If a dataset has an edit - give that value. If it doesn't have an edit,
  # fall back to the default value.
  def value
    latest ? latest.value : default
  end

  private

  def is_atlas_attribute?
    @dataset.atlas_dataset &&
      @dataset.atlas_dataset.attributes.keys.include?(@key.to_sym)
  end
end
