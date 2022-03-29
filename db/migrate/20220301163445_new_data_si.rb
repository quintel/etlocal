class NewDataSi < ActiveRecord::Migration[5.0]
  def self.up
    directory    = Rails.root.join('db/migrate/20220301163445_new_data_si')
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
    CSVImporter.run(data_path, commits_path, create_missing_datasets: true) do |row, runner|
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
