class DatasetPolicy < ApplicationPolicy
  def edit?
    (record.user == user) || (record.user.group == user.group)
  end

  alias_method :update?, :edit?
  alias_method :download?, :edit?
end
