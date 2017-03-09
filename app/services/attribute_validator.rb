module AttributeValidator
  def self.valid?(edits)
    Dataset::EDITABLE_ATTRIBUTES.keys.all? do |key|
      edits[key].present? && edits[key].is_a?(Numeric)
    end
  end
end
