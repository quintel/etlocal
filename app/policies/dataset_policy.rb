class DatasetPolicy < ApplicationPolicy
  def edit?
    true
  end

  def update?
    true
  end

  def download?
    true
  end
end
