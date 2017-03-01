class DatasetPolicy < ApplicationPolicy
  def show?
    scope.find(record.area).present?
  end
end
