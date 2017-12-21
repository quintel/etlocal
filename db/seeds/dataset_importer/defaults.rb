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
        edit = @dataset.edits.find_by(key: key)

        # If we have an older dataset edit
        if edit
          # If the commit is from the Robot user and the value is changed
          if edit.commit.user == User.robot && edit.value != value
            edit.update_attribute(:value, value)
          end
        elsif value =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/
          commit.dataset_edits.create!(key: key, value: value)
        end
      end
    end

    private

    def commit
      @commit ||= begin
        commit = @dataset.commits.find_by(user: User.robot)

        if commit.nil?
          commit = @dataset.commits.new
          commit.user = User.robot
          commit.message = "Initial value Quintel <a href='https://www.cbs.nl' target='_blank'>CBS</a>"
          commit.save
          commit
        end

        commit
      end
    end
  end
end
