class MapTransformer
  require 'geo_ruby/shp'

  # Class to turn *.shp files to *.kml files
  def initialize
    @country = "nl".freeze
  end

  def transform
    Dir[root.join("*.shp")].map do |path|
      name = File.basename(path, ".shp")

      provinces_municipality.each_pair do |gm_code, province|
        dir = "public/kml/#{ province.downcase }"

        FileUtils.mkdir(dir) unless Dir.exists?(dir)

        %x[ ogr2ogr -f 'KML' -select "GM_CODE" -where "GM_CODE='GM#{ gm_code }'" #{ dir }/#{ [gm_code, name].join("_") }.kml #{ path } ]
      end
    end
  end

  private

  def provinces_municipality
    @provinces_municipality ||= Hash[
      CSV.read(root.join("provinces_municipality.csv"), headers: true, skip_blanks: true).map do |row|
        [row["Gemeentecode"], row["Provincienaam"]]
      end
    ]
  end

  def root
    Rails.root.join("db", "shapes", @country)
  end
end
