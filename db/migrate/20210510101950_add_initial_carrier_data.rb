class AddInitialCarrierData < ActiveRecord::Migration[5.2]
  Cell = Struct.new(:carrier, :key, :value) do
    def interface_key
      "files_carriers_#{carrier}_#{key}"
    end
  end

  def up
    carrier_values = build_carrier_values

    message = <<-MSG.strip_heredoc
      Add emissions and costs for energy carriers using data for the Netherlands.
    MSG

    say_with_time('Adding carrier data') do
      datasets   = Dataset.order(:geo_id)
      length     = datasets.count
      len_width  = length.to_s.length

      datasets.find_each.with_index do |dataset, index|
        commit = dataset.commits.build(message: message, user: User.robot)

        carrier_values.each do |cv|
          commit.dataset_edits.build(key: cv.interface_key, value: cv.value)
        end

        commit.save!

        say(
          "#{format("%#{len_width}d", index + 1)}/#{length}: " \
          "#{dataset.geo_id} #{dataset.name} (#{dataset.id})"
        )
      end
    end
  end

  def down
    say_with_time('Removing carrier data') do
      carrier_values = build_carrier_values
      keys = carrier_values.map(&:interface_key)

      dataset_edits = DatasetEdit.select(%i[id commit_id]).where(key: keys)
      commits = Commit.where(id: dataset_edits.map(&:commit_id).uniq)

      commits_len = commits.length

      dataset_edits.delete_all

      commits.find_each.with_index do |commit, index|
        say("Commit #{index}/#{commits_len}") if (index % 100).zero?
        commit.destroy! if commit.dataset_edits.count.zero?
      end

      say("Commit #{commits_len}/#{commits_len}")
    end
  end

  private

  def build_carrier_values
    table = CSV.table(
      Rails.root.join('db/migrate/20210510101950_add_initial_carrier_data/carriers.csv'),
      headers: true
    )

    table.flat_map do |row|
      carrier = row[:key]

      row.map do |key, value|
        Cell.new(carrier, key, value) if key != :key && value.present?
      end.compact
    end
  end
end
