# frozen_string_literal: true

# Adds region-specific carrier data.
class AddInitialCarrierData < ActiveRecord::Migration[5.2]
  Cell = Struct.new(:carrier, :key, :value) do
    def interface_key
      "file_carriers_#{carrier}_#{key}"
    end
  end

  def up
    message = <<-MSG.strip_heredoc
      Add emissions and costs for energy carriers using data for the Netherlands.
    MSG

    say_with_time('Adding carrier data') do
      datasets   = Dataset.order(:geo_id)
      length     = datasets.count
      len_width  = length.to_s.length

      datasets.find_each.with_index do |dataset, index|
        region_used, carrier_values = carrier_values_for(dataset.geo_id)
        commit = dataset.commits.build(message: message, user: User.robot)

        carrier_values.each do |cv|
          commit.dataset_edits.build(key: cv.interface_key, value: cv.value)
        end

        commit.save!

        say(
          "#{format("%#{len_width}d", index + 1)}/#{length}: " \
          "#{dataset.geo_id} #{dataset.name} using data for #{region_used}"
        )
      end
    end
  end

  def down
    say_with_time('Removing carrier data') do
      _, carrier_values = carrier_values_for(:nl)
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

  def carrier_values_for(region_code)
    @carrier_values ||= build_carrier_values

    region_code = region_code.to_sym

    return [region_code, @carrier_values[region_code]] if @carrier_values.key?(region_code)

    dataset = Dataset.find_by!(geo_id: region_code)
    atlas_key = dataset.atlas_key.to_sym

    return [atlas_key, @carrier_values[atlas_key]] if @carrier_values.key?(atlas_key)

    parent = dataset.base_dataset.to_sym

    if @carrier_values[parent]
      [parent, @carrier_values[parent]]
    else
      [:nl, @carrier_values[:nl]]
    end
  end

  def build_carrier_values
    say_with_time('Building carrier values') do
      files = Rails.root.join('db/migrate/20210510101950_add_initial_carrier_data').glob('*.csv')

      files.each_with_object({}) do |path, data|
        data[path.basename.sub_ext('').to_s.to_sym] = build_values_from_path(path)
      end
    end
  end

  def build_values_from_path(path)
    table = CSV.table(Rails.root.join(path), headers: true)

    table.flat_map do |row|
      carrier = row[:key]

      row.map do |key, value|
        Cell.new(carrier, key, value) if key != :key && value.present?
      end.compact
    end
  end
end
