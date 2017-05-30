class SliderGroup
  def self.expand(dataset, sliders, edits, group)
    sliders.fetch(group.to_sym).map do |key, default|
      EditableAttribute.new(dataset, key, edits,
        'default' => default, 'group' => group, 'slider' => true)
    end
  end
end
