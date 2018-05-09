require 'progress_bar'

# Initializes the database with defaults
#
#  * This will create a new dataset only if the old one doesn't exist
#  * This will create a single commit for that dataset only if the old one
#    doesn't exist
#  * This will create new 'dataset_edits' for every row in the CSV and add
#    that to that commit. There are no checks if the relevant edit already
#    exists. The reason that was removed is due to slowness.

class DatasetImporter
  def initialize(country = 'nl')
    @country = country
  end

  def valid?
    begin
      datasets
    rescue Errno::ENOENT
      false
    end
  end

  def import
    destroy_old_values!

    edits = []
    bar   = ProgressBar.new(datasets.size)
    scope = Dataset.all.each_with_object({}) do |el, hash|
      hash[el.geo_id] = el
    end

    datasets.each_slice(100) do |batch|
      batch.each do |row|
        dataset_row = DatasetCSVRow.new(row.to_h)
        dataset     = (
          scope[dataset_row.geo_id] ||
          Dataset.create!(
            geo_id: dataset_row.geo_id,
            area: dataset_row.area,
            user: User.robot
          )
        )

        edits = edits + Defaults.get(dataset, dataset_row)

        bar.increment! if Rails.env.development?
      end

      if edits.any?
        ActiveRecord::Base.connection.execute("INSERT INTO dataset_edits (`key`, `value`, `commit_id`, `created_at`, `updated_at`) VALUES #{edits.join(", ")}")

        edits.clear
      end
    end
  end

  private

  def destroy_old_values!
    puts "Down with the old defaults..." if Rails.env.development?

    DatasetEdit.where(commit_id: Commit.where(user: User.robot).pluck(:id)).delete_all
  end

  def datasets
    @datasets ||= CSV.read(
      Rails.root.join("db", "datasets", "#{ @country }_datasets.csv"),
      headers: true
    )
  end
end
