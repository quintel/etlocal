class Dataset
  def self.all
    Etsource.collection
  end

  def self.find(area)
    all.detect do |dataset|
      dataset.area == area
    end
  end
end
