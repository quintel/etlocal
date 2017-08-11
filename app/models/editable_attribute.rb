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

  def slider?
    !!@options['slider']
  end

  def previous
    @edits[@key] || []
  end

  def latest
    previous.first
  end

  def default
    return unless is_atlas_attribute?

    if @dataset.atlas_dataset
      @dataset.atlas_dataset.public_send(@key)
    else
      parent_dataset = Atlas::Dataset.find(@dataset.country)

      parent_dataset.public_send(@key) ||
        Dataset.defaults.fetch(@key.to_sym)
    end
  end

  # If a dataset has an edit - give that value. If it doesn't have an edit,
  # fall back to the default value.
  def value
    latest ? latest.parsed_value : default
  end

  private

  def is_atlas_attribute?
    Atlas::Dataset.attribute_set
      .map(&:name)
      .include?(@key.to_sym)
  end
end
