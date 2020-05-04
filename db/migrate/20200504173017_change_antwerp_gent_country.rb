class ChangeAntwerpGentCountry < ActiveRecord::Migration[5.2]
  BELGIAN_GEO_IDS = ['BEBU4402101', 'BEGM11002'].freeze

  def self.up
    Dataset.find_each do |dataset|
      dataset.country = 'be' if BELGIAN_GEO_IDS.include? dataset.geo_id
      dataset.save(validate: false, touch: false)
    end
  end

  def self.down
    Dataset.find_each do |dataset|
      dataset.country = 'nl' if BELGIAN_GEO_IDS.include? dataset.geo_id
      dataset.save(validate: false, touch: false)
    end
  end
end
