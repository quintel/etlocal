namespace :db do
  desc "Reset database to a specific version by removing commits created after the version's freeze date"
  task :reset_to_version, [:version_name] => :environment do |task, args|
    version_name = args[:version_name]

    if version_name.blank?
      puts "Usage: rake db:reset_to_version[version_name]"
      puts "Example: rake db:reset_to_version[2025.01]"
      exit 1
    end

    begin
      versions_config = YAML.load_file(Rails.root.join('config/versions.yml'))
      version = versions_config['versions'].find { |v| v['name'] == version_name }

      raise ArgumentError, "Version '#{version_name}' not found" unless version
      raise ArgumentError, "Version '#{version_name}' has no freeze_date" if version['freeze_date'].nil?

      freeze_date = Time.parse(version['freeze_date'])

      puts "Resetting database to version '#{version_name}' (freeze date: #{freeze_date})"
      puts "This will permanently delete all commits created after #{freeze_date}"
      print "Are you sure? [y/N]: "

      confirmation = STDIN.gets.chomp.downcase
      unless confirmation == 'y' || confirmation == 'yes'
        puts "Operation cancelled."
        exit 0
      end

      # Find all commits created after the freeze date
      commits_to_remove = Commit.where('created_at > ?', freeze_date)

      if commits_to_remove.empty?
        puts "No commits found after the freeze date. Database is already in the correct state."
      else
        puts "Found #{commits_to_remove.count} commit(s) to remove..."

        # Delete commits (Irreversible - only do this locally!)
        ActiveRecord::Base.transaction do
          commits_to_remove.destroy_all
        end

        puts "Successfully removed #{commits_to_remove.count} commit(s)."
      end

      puts "Reset to version '#{version_name}' completed successfully!"

    rescue ArgumentError => e
      puts "Error: #{e.message}"
      exit 1
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
      puts e.backtrace if ENV['DEBUG']
      exit 1
    end
  end
end
