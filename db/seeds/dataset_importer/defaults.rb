class DatasetImporter
  module Defaults
    module_function

    NUMBER_REGEX = /\A[-+]?[0-9]*\.?[0-9]+\Z/

    def set(dataset, csv_row)
      @dataset = dataset

      commit = find_or_create_commit!

      csv_row.editable_attributes.each do |key, value|
        if edit = @dataset.edits.detect{ |e| e.key == key }
          next unless edit.commit.user == User.robot && edit.value != value

          edit.update_attribute(:value, value)
        elsif value =~ NUMBER_REGEX
          commit.dataset_edits.create!(key: key, value: value)
        end
      end
    end

    def find_or_create_commit!
      @dataset.commits.detect{ |c| c.user == User.robot } ||
      @dataset.commits.create!(
        user:    User.robot,
        message: "Initial value Quintel <a href='https://www.cbs.nl' target='_blank'>CBS</a>"
      )
    end
  end
end
