module DatasetCloner
  module_function

  def clone!(dataset, user)
    clone = dataset.deep_clone include: { commits: :dataset_edits }
    clone.assign_attributes(user: user, public: false)
    clone.save
    clone
  end
end
