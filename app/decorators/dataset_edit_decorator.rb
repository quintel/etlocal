class DatasetEditDecorator
  def self.decorate(dataset_edits)
    new(dataset_edits).decorate
  end

  def initialize(dataset_edits)
    @dataset_edits = dataset_edits
  end

  def decorate
    @dataset_edits.all.each_with_object({}) do |edit, object|
      object[edit.key] = edit.value
    end
  end
end
