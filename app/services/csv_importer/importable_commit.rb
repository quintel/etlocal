# frozen_string_literal: true

class CSVImporter
  # Internal: Describes a collection of attributes which will be imported and
  # a message to be assigned to the resulting commit.
  class ImportableCommit
    attr_reader :keys, :message

    def initialize(keys, message)
      @keys = keys
      @message = message
    end

    def build_commit(dataset, row)
      raise 'Commit is missing a message' unless @message.present?

      commit = Commit.new(dataset: dataset, message: @message, user: User.robot)
      current = dataset.editable_attributes

      @keys.each do |key|
        value = DatasetEdit.cast_from_csv(key, row[key.to_s])
        next if value.nil?

        attribute = current.find(key)

        # Skip if value unchanged and already has an edit
        next if value_unchanged_with_existing_edit?(value, attribute)

        commit.add_dataset_edit(key, value)
      end

      commit
    end

    private

    def value_unchanged_with_existing_edit?(value, attribute)
      return false unless attribute&.latest

      current_value = attribute.latest.cast_value
      value == current_value
    end
  end
end
