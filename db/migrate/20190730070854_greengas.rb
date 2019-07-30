class Greengas < ActiveRecord::Migration[5.0]
  def change

    production_key = 'input_energy_greengas_production'
    import_key = 'energy_import_greengas_demand'
    new_key = 'energy_distribution_greengas_demand'

    Dataset.find_each do | dataset |

      production = 0
      commits = []

      Commit.where(dataset_id: dataset.id).order(updated_at: :asc).find_each do | commit |
        commits << commit.id
      end

      # find most recent value of production key
      DatasetEdit.where(commit_id: commits, key: production_key).order(updated_at: :desc).limit(1).each do | edit |
        production = edit.value
      end

      # find most recent value of import key
      DatasetEdit.where(commit_id: commits, key: import_key).order(updated_at: :desc).limit(1).each do | edit |
        # add production value to import value, rename import key
        edit.value += production
        edit.key = new_key
        edit.save
      end
    end
  end
end