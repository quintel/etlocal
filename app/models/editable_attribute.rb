class EditableAttribute
  attr_reader :key

  def initialize(dataset, key, edits, default = nil, entso_query: nil)
    @dataset     = dataset
    @key         = key
    @edits       = edits
    @default     = default
    @entso_query = entso_query
  end

  def inspect
    "#<#{self.class.name} dataset=#{@dataset.geo_id.inspect} " \
      "key=#{@key.inspect} value=#{value.inspect}>"
  end

  def previous
    @edits[@key] || []
  end

  def latest
    previous.first
  end

  # Defaults for atlas attributes
  #
  # If the dataset already exists in ETSource, assume from that dataset.
  # If there's a default specified in the default value options on the
  # attribute (like `has_industry` or `has_agriculture`) use that one.
  #
  def default
    @default || atlas_default
  end

  # If a dataset has an edit - give that value. If it doesn't have an edit,
  # fall back to the default value.
  def value
    if @dataset.queryable_source? && @entso_query.present?
      return @dataset.execute_query(@entso_query)
    end

    latest ? latest.value : default
  end

  private

  def atlas_default
    return unless is_atlas_attribute?

    if @dataset.atlas_dataset
      @dataset.atlas_dataset.public_send(@key)
    elsif %w(has_industry has_agriculture).include?(@key)
      @dataset.public_send(@key)
    end
  end

  def is_atlas_attribute?
    Atlas::Dataset.attribute_set
      .map(&:name)
      .include?(@key.to_sym)
  end
end
