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

        if value && value != current.find(key).value
          commit.dataset_edits.build(key: key, value: value)
        end
      end

      commit
    end
  end
end
