class EditableAttribute
  attr_reader :key

  def initialize(key, options = {})
    @key     = key
    @options = options
  end

  def unit
    @options['unit']
  end
end
