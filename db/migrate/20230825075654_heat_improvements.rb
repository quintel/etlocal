class HeatImprovements < ActiveRecord::Migration[5.0]

  KEYS = {
    # old_key: :new_key
    input_energy_chp_ultra_supercritical_coal_production: :input_energy_chp_ultra_supercritical_ht_coal_production,
    input_energy_chp_ultra_supercritical_cofiring_coal_production: :input_energy_chp_ultra_supercritical_cofiring_ht_coal_production,
    input_energy_chp_ultra_supercritical_lignite_production: :input_energy_chp_ultra_supercritical_ht_lignite_production,
    input_energy_chp_combined_cycle_network_gas_production: :input_energy_chp_combined_cycle_ht_network_gas_production,
    input_energy_chp_local_engine_network_gas_production: :input_energy_chp_local_engine_ht_network_gas_production,
    input_energy_chp_supercritical_waste_mix_production: :input_energy_chp_supercritical_ht_waste_mix_production,
    input_energy_chp_local_wood_pellets_production: :input_energy_chp_local_ht_wood_pellets_production,
    input_energy_chp_local_engine_biogas_production: :input_energy_chp_local_engine_ht_biogas_production,
    input_energy_heat_well_geothermal_production: :input_energy_heat_well_ht_geothermal_production,
    input_energy_heat_burner_wood_pellets_production: :input_energy_heat_burner_ht_wood_pellets_production,
    input_energy_heat_burner_waste_mix_production: :input_energy_heat_burner_ht_waste_mix_production,
    input_energy_heat_burner_hydrogen_production: :input_energy_heat_burner_ht_hydrogen_production,
    input_energy_heat_heatpump_water_water_electricity_production: :input_energy_heat_heatpump_water_water_ht_electricity_production,
    input_energy_heat_boiler_electricity_production: :input_energy_heat_boiler_ht_electricity_production,
    input_energy_heat_burner_network_gas_production: :input_energy_heat_burner_ht_network_gas_production,
    input_energy_heat_burner_coal_production: :input_energy_heat_burner_ht_coal_production,
    input_energy_heat_burner_crude_oil_production: :input_energy_heat_burner_ht_crude_oil_production
  }

  def self.up
    # @THOMAS: Could you add some lines to rename the old keys to the new keys (and keep the old value) for all datasets?
    # Should we create a separate migration for this action?

    directory    = Rails.root.join('db/migrate/20230825075654_heat_improvements')
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
