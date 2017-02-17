module Etsource
  def self.collection(datasets = nil)
    @datasets ||= datasets
  end
end
