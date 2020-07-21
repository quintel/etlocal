class RemoveErroneousCommits < ActiveRecord::Migration[5.2]
  COMMITS = [
    259971,
    263950,
    263953,
    258910,
    258920,
    258912,
    258914,
    258919,
    263952,
    263954,
    258907,
    258917,
    258918,
    263951,
    263948,
    263949,
    258921,
    258922,
    319320,
    319321,
    319315,
    319316,
    319317
  ].freeze
  def self.up
    COMMITS.each do |id|
      Commit.destroy(id)
      DatasetEdit.where(commit_id: id).destroy_all
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
