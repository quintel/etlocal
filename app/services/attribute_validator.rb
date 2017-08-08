class AttributeValidator
  def initialize(edits)
    @edits = edits
  end

  def valid?
    !missing.any?
  end

  def message
    missing.keys.join(', ')
  end

  private

  def missing
    Dataset::EDITABLE_ATTRIBUTES.select do |key, opts|
      opts['mandatory'] && @edits[key].blank?
    end
  end
end
