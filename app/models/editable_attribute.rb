class EditableAttribute
  attr_reader :key

  def initialize(key, options = {})
    @key     = key
    @options = options
  end
end
