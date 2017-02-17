module Etsource
  def self.collection(datasets = nil)
    @collection ||= datasets
  end
end
