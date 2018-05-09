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

  alias_method :update?, :edit?
end
