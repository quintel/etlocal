class NameDatasetsCorrectly < ActiveRecord::Migration[5.0]
  def up
    area_names = YAML.load_file(Rails.root.join("db", "migrate", "20180206102839_name_datasets_correctly", "translations.yml"))

    Dataset.all.each do |dataset|
      dataset.update_attribute(:area, area_names[dataset.geo_id])
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
