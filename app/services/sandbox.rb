# Creates a temporary dataset and the means to execute arbitrary Rubel queries
# in Rubel runtime.
class Sandbox
  def initialize(dataset)
    @runtime = nil
    @dataset = dataset
    @dataset_name = dataset.temp_name
  end

  # Public: Sets up the sandbox and permits execution of Rubel during the
  # provided block.
  #
  # Yields the sandbox.
  #
  # For example:
  #
  #   Sandbox.new(Dataset.first).run do |sandbox|
  #     sandbox.execute('SUM(1, 2, 3)') # => 6
  #   end
  #
  # Returns the value of the last Rubel expression evaluated.
  def run
    attributes = dataset_attributes

    begin
      @runtime = runtime(
        Transformer::DatasetGenerator.new(attributes).generate()
      )

      yield(self)
    ensure
      @runtime = nil

      Atlas::Dataset.exists?(@dataset_name) &&
        Atlas::Dataset.find(@dataset_name).destroy!
    end
  end

  # Public: Executes the provided `query` in the Rubel runtime.
  #
  # query - The query as a string.
  #
  # Returns the value of the evaluated expression. Raises an error if called
  # outside of a `run` block.
  def execute(query)
    raise "Cannot execute sandbox query outside of `run' block" unless @runtime
    @runtime.execute(query)
  end

  private

  def dataset_attributes
    @dataset.editable_attributes.as_json.merge(
      area: @dataset_name,
      base_dataset: @dataset.country
    )
  end

  def runtime(cast)
    Transformer::Caster::Base.new(
      cast,
      Transformer::Caster::Template.new
    ).runtime
  end
end
