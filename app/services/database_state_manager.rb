class DatabaseStateManager
  class << self
    def reset_to_version!(version_name)
      versions_config = YAML.load_file(Rails.root.join('config/versions.yml'))
      version = versions_config['versions'].find { |v| v['name'] == version_name }

      raise ArgumentError, "Version '#{version_name}' not found" unless version
      raise ArgumentError, "Version '#{version_name}' has no freeze_date" if version['freeze_date'].nil?

      freeze_date = Time.parse(version['freeze_date'])

      # --- DATA LEVEL OPERATION ---
      # Find all commits created after the freeze date. DELETE them (Irreversible - only do this locally)
      commits_to_remove = Commit.where('created_at > ?', freeze_date)
      ActiveRecord::Base.transaction do
        commits_to_remove.destroy_all
      end

      # WE NEED TO LOAD THE SCHEMA FROM THE CORRECT COMMIT - THE SCHEMA SHOULD BE IN THE CORRECT STATE ON STABLE

      puts "Reset to version '#{version_name}' (#{freeze_date})"
    end
  end
end
