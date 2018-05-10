class DatasetPolicy < ApplicationPolicy
  def edit?
    (record.user == user) || (record.user.group == user.group)
  end

  def clone?
    record.public? || edit?
  end

  def download?
    false
  end

  def sandbox?
    user.group_id == quintel_group.id
  end

  alias_method :update?, :edit?
end
