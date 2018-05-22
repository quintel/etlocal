class DatasetPolicy < ApplicationPolicy
  def edit?
    return false unless user

    (record.user == user) || (record.user.group == user.group)
  end

  def clone?
    user && (record.public? || edit?)
  end

  def download?
    false
  end

  alias_method :update?, :edit?
end
