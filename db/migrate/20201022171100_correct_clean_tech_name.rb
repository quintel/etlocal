class CorrectCleanTechName < ActiveRecord::Migration[5.2]
  def self.up
    Dataset.find_each do |dataset|
      dataset.name = 'Cleantech Regio' if dataset.name == 'Cleantech'
      dataset.save(validate: false, touch: false)
    end
  end

  def self.down
    Dataset.find_each do |dataset|
      dataset.name = 'Cleantech' if dataset.name == 'Cleantech Regio'
      dataset.save(validate: false, touch: false)
    end
  end
end
