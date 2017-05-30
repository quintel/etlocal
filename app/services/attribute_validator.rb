module AttributeValidator
  def self.valid?(edits)
    Dataset::EDITABLE_ATTRIBUTES
      .select { |_, opts| opts['mandatory'] }
      .all? do |key, options|
        edits[key].present? && edits[key].is_a?(Numeric)
      end
  end
end
