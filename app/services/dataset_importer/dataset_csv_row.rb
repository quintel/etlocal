class DatasetImporter
  class DatasetCSVRow
    attr_reader :geo_id, :area

    def initialize(attributes = {})
      @attributes = attributes
      @geo_id, @area = set_attributes
    end

    private

    def set_attributes
      case type
      when "GM"
        [ "GM#{ municipality_code }",
          @attributes.fetch('municipality') ]
      when "WK"
        [ "WK#{ municipality_code }#{ district_code }",
          @attributes.fetch('district') ]
      when "BU"
        [ "BU#{ municipality_code }#{ district_code }#{ neighborhood_code }",
          @attributes.fetch('area_name') ]
      end
    end

    def municipality_code
      @attributes.fetch('municipality_code').rjust(4, "0")
    end

    def district_code
      @attributes.fetch('district_code').rjust(2, "0")
    end

    def neighborhood_code
      @attributes.fetch('neighborhood_code').rjust(2, "0")
    end

    def type
      @attributes.fetch('type')
    end
  end
end
