class InputsDecorator
  def self.decorate(inputs)
    new(inputs).decorate
  end

  def initialize(inputs)
    @inputs = inputs
  end

  def decorate
    @inputs.sort_by(&:group)
       .group_by(&:group)
       .map do |group, inputs|
         [group, inputs.sort.group_by(&:share_group)]
       end
  end
end
