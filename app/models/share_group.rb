class ShareGroup
  def initialize(share_group, user, dataset, commit_params)
    @share_group   = share_group.to_sym
    @user          = user
    @dataset       = dataset
    @commit_params = commit_params
  end

  def build
    inputs_for_share_group.map do |input|
      DatasetEdit.new(key: input.key)
    end
  end

  def save
    commit = @user.commits.new(@commit_params)
    commit.dataset_edits = build
    commit.save
  end

  private

  def inputs_for_share_group
    Input.all.select do |input|
      input.share_group == @share_group
    end
  end
end
