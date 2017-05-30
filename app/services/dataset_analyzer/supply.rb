module DatasetAnalyzer
  class Supply < Base
    def analyze
      @dataset_edits.slice(*supply_attributes.keys)
    end

    private

    # Please remove for this is quiet hacky
    def supply_attributes
      Dataset::EDITABLE_ATTRIBUTES.select do |_, edit|
        edit['group'] == 'supply'
      end
    end
  end
end
