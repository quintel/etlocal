class UpdateBuiltEnvironmentStockForSingapore < ActiveRecord::Migration[5.0]
  def self.up
    directory    = Rails.root.join('db/migrate/20240110105756_update_built_environment_stock_for_singapore')
    data_path    = directory.join('data.csv')
    commits_path = directory.join('commits.yml')
    datasets     = []

    # By default, CSVImporter only allows updating existing datasets. If the
    # migration is adding a new dataset, add the `create_missing_datasets`
    # keyword argument. For example:
    #
    #   CSVImporter.run(data_path, commits_path, create_missing_datasets: true) do |row, runner|
    #     # ...
    #   end
    #
    CSVImporter.run(data_path, commits_path) do |row, runner|
      print "Updating #{row['geo_id']}... "
      commits = runner.call

      if commits.any?
        datasets.push(find_dataset(commits))
        puts 'done!'
      else
        puts 'nothing to change!'
      end
    end

    sleep(1)
    puts
    puts "Updated #{datasets.length} datasets with the following IDs:"
    puts "  #{datasets.map(&:id).join(',')}"
  rescue ActiveRecord::RecordInvalid => e
    if e.record.is_a?(Commit) && e.record.errors['dataset_edits.value'].any?
      warn('')
      warn('-' * 80)
      warn('The following errors occurred while processing CSV rows:')
      warn('')

      # Grab all the errors from individual datasets to show those instead. This is typically
      # the case when a CSV specifies a value that is not allowed to be edited.
      e.record
        .dataset_edits
        .reject(&:valid?)
        .each do |edit|
          edit.errors.each do |field, msg|
            warn("* #{edit.commit.dataset.geo_id}: #{edit.key}: #{field} #{msg}")
          end
        end

      warn('-' * 80)
    end

    raise e
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

  def find_dataset(commits)
    commits.each do |commit|
      return commit.dataset if commit&.dataset
    end
  end
end
