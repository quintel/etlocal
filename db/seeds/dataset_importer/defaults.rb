class DatasetImporter
  module Defaults
    module_function

    NUMBER_REGEX = /\A[-+]?[0-9]*\.?[0-9]+\Z/

    def get(dataset, csv_row)
      commit = find_or_create_commit!(dataset)
      new_edits = []
      time = Time.now.to_s(:db)

      csv_row.editable_attributes.each do |key, value|
        if value =~ NUMBER_REGEX
          new_edits.push("('#{key}', #{value}, #{commit.id}, '#{time}', '#{time}')")
        end
      end

      new_edits
    end

    def find_or_create_commit!(dataset)
      dataset.commits.detect{ |c| c.user == User.robot } ||
      dataset.commits.create!(
        user:    User.robot,
        message: "Initial value Quintel <a href='https://www.cbs.nl' target='_blank'>CBS</a>"
      )
    end
  end
end
