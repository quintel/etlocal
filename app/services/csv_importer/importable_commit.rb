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
        raw_value = row[key.to_s]
        attribute = current.find(key)
        latest_edit = attribute&.latest
        has_existing_edit = latest_edit.present?
        value = DatasetEdit.cast_from_csv(key, raw_value)
        if value.nil?
          next
        end

        current_value = DatasetEdit.current_value_for(attribute)

        if value == current_value
          if has_existing_edit
            next
          end

          DatasetEdit.build_for(commit, key, value)
          next
        end

        DatasetEdit.build_for(commit, key, value)
      end

      commit
    end
  end
end
