# frozen_string_literal: true

class CSVImporter
  class ImportableCommit
    attr_reader :keys, :message

    def initialize(keys, message)
      @keys = keys
      @message = message
    end

    def build_commit(dataset, row)
      raise 'Commit is missing a message' unless @message.present?

      Commit.new(dataset: dataset, message: @message, user: User.robot).tap do |commit|
        build_edits_for(commit, dataset, row)
      end
    end

    private

    def build_edits_for(commit, dataset, row)
      current = dataset.editable_attributes

      @keys.each do |key|
        value = DatasetEdit.cast_from_csv(key, row[key.to_s])
        next if value.nil?

        attribute = current.find(key)
        current_value = DatasetEdit.current_value_for(attribute)

        # Only skip if value matches and there's an existing edit
        next if value == current_value && attribute&.latest.present?

        DatasetEdit.build_for(commit, key, value)
      end
    end
  end
end
