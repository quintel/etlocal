class AddDummyValuesToEmptyKeys < ActiveRecord::Migration[5.2]

  def self.up
    say "Checking and migrating #{Dataset.count} datasets"
    changed = 0

    ds_sk = Dataset.find_by(geo_id: 'SK')
    empty_fields = ds_sk.editable_attributes.as_json.reject{ |k,v| v }.keys

    Dataset.where(geo_id: ['SK','DE']).each do |dataset|
        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'Dummy value: set to zero to test export'
          )

          empty_fields.each do |key, value|
            create_edit(com, key, 0.0)
          end

          com.save!
        end

      changed += 1
    end
    say "Finished (#{changed} updated)"
  end

  private

  # Create a new dataset edit
  def create_edit(commit, key, value)
    ActiveRecord::Base.transaction do
      DatasetEdit.create!(
        commit_id: commit.id,
        key: key,
        value: value
      )
    end
  end
end
