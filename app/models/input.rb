class Input
  def self.all
    Etsource.inputs
  end

  def initialize(atlas_input)
    @atlas_input = atlas_input
  end

  def key
    @atlas_input.key
  end
end
