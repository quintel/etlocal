# frozen_string_literal: true

# Performs an initial import of data from db/datasets into a new database.
#
# * For each row in the dataset where the a matching geo_id is not already
#   present, the dataset will be created and data added to the database.
#
# * For each row where the dataset already exists the database will be updated
#   with information from the CSV.
class DatasetImporter
  delegate :valid?, :errors, to: :importer

  def initialize(dir)
    @dir = Pathname.new(dir)
  end

  def import
    return false unless valid?

    destroy_old_values!
    import_data!

    true
  end

  private

  def destroy_old_values!
    # Delete all commits belonging to datasets owned by the Robot.
    commits = Commit.select(:id)
      .includes(:dataset)
      .where(datasets: { user: User.robot })

    bar = create_progress_bar('Removing old data', commits.count)

    commits.find_in_batches(batch_size: 100) do |group|
      DatasetEdit.where(commit_id: group.map(&:id)).delete_all
      group.each(&:destroy)

      bar.advance(group.length) if Rails.env.development?
    end
  end

  def import_data!
    bar = create_progress_bar(
      'Importing data',
      `wc -l #{@dir.join('data.csv').to_s.shellescape}`.split.first.to_i -
        (csv_ends_with_newline? ? 1 : 0)
    )

    importer.run do |_row, runner|
      runner.call
      bar.advance if Rails.env.development?
    end
  end

  def importer
    @importer ||= CSVImporter.new(
      @dir.join('data.csv'),
      @dir.join('commits.yml'),
      create_missing_datasets: true
    )
  end

  def create_progress_bar(title, total)
    TTY::ProgressBar.new(
      "#{title} [:bar] :current/:total (:percent)",
      frequency: 10, total: total, width: TTY::Screen.width
    )
  end

  def csv_ends_with_newline?
    path = @dir.join('data.csv')
    %W[\n \r].include?(path.read(1, path.size - 1))
  end
end
