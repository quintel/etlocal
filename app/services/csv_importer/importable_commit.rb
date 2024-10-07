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
      commit = Commit.new(dataset: dataset, message: @message, user: User.robot)

      raise 'Commit is missing a message' unless @message.present?

      current = dataset.editable_attributes

      @keys.each do |key|
        value = row[key]

        # Use the custom `find` method which expects a key
        current_attr = current.find(key)

        if value
          if current_attr
            if value != current_attr.value
              commit.dataset_edits.build(key: key, value: value)
            end
          else
            # Log a warning if the key is not found in editable_attributes
            warn "Warning: Key '#{key}' not found in editable_attributes for dataset '#{dataset.geo_id}'. Skipping this key."
          end
        end
      end

      commit
    end
  end
end