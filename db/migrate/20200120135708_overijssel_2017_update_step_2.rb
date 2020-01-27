class Overijssel2017UpdateStep2 < ActiveRecord::Migration[5.0]
  def self.up
    directory    = Rails.root.join('db/migrate/20200120135708_overijssel_2017_update_step_2')
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
        datasets.push(commits.first.dataset)
        puts 'done!'
      else
        puts 'nothing to change!'
      end
    end

    puts
    puts "Updated #{datasets.length} datasets with the following IDs:"
    puts "  #{datasets.map(&:id).join(',')}"
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
