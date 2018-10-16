class MunicUpdateStep1 < ActiveRecord::Migration[5.0]
  def self.up
    directory    = Rails.root.join('db/migrate/20181016092640_munic_update_step1')
    data_path    = directory.join('data.csv')
    commits_path = directory.join('commits.yml')
    datasets     = []

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
