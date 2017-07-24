class DatasetImporter
  class Defaults
    def self.set(dataset, csv_row)
      new(dataset, csv_row).update_defaults
    end

    def initialize(dataset, csv_row)
      @dataset = dataset
      @csv_row = csv_row
    end

    def update_defaults
      @csv_row.editable_attributes.each do |key, value|
        if dataset_edit = find_edit_from_commit(key)
          dataset_edit.update_attribute(:value, value)
        elsif dataset_edit_changed?(key)
          DatasetEdit.create(key: key, value: value, commit: Commit.new(
            user:    User.robot,
            dataset: @dataset,
            message: "Initial value Quintel"
          ))
        end
      end
    end

    private

    def find_edit_from_commit(key)
      find_edits(key).where("`commits`.`user_id` = ?", User.robot).first
    end

    def dataset_edit_changed?(key)
      find_edits(key).where("`commits`.`user_id` != ?", User.robot).empty?
    end

    def find_edits(key)
      dataset_edits.where(key: key)
    end

    def dataset_edits
      @dataset_edits ||= DatasetEdit.joins(:commit)
        .where("`commits`.`dataset_id` = ?", @dataset)
    end
  end
end
