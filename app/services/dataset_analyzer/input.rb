class Input
  def self.all
    Atlas::InitializerInput.all
  end

  def initialize(atlas_input)
    @atlas_input = atlas_input
  end

  def group
    File.split(@atlas_input.path.dirname)[1..-1].join("_")
  end

  # Public: sort
  #
  # Sorts out the inputs by share group. If a share group is present
  # that group will be sorted out last.
  def <=> (other)
    if share_group && other.share_group
      share_group <=> other.share_group
    else
      share_group ? 1 : -1
    end
  end

  def share_group
    @atlas_input.share_group
  end

  def key
    @atlas_input.key
  end

  alias_method :name, :key
end
