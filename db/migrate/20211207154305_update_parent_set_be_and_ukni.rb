class UpdateParentSetBeAndUkni < ActiveRecord::Migration[5.2]
  REGIONAL_EU_DATASETS = %w[
    UKNI01 DE1 DE2 DE3 DE4 DE5 DE6 DE7 DE8 DE9 DEA DEB DEC DED DEE DEF DEG BE1 BE2 BE3 BEBU4402101
    BEGM11002 BEGM13040 BEGM35013
  ].freeze

  def change
    Dataset.where(geo_id: REGIONAL_EU_DATASETS).update_all(country: 'eu')
  end
end
