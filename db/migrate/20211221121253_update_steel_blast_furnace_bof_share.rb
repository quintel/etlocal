class UpdateSteelBlastFurnaceBofShare < ActiveRecord::Migration[5.2]
  NEW_VALUES = {
    AT: 0.904,
    BE: 0.675,
    BG: 0.0,
    CY: 0.0,
    CZ: 0.947,
    DE: 0.7,
    DK: 0.0,
    EE: 0.0,
    ES: 0.312,
    FI: 0.6679999999999999,
    FR: 0.696,
    UK: 0.7879999999999999,
    EL: 0.0,
    HR: 0.0,
    HU: 0.8009999999999999,
    IE: 0.0,
    IT: 0.181,
    LT: 0.0,
    LU: 0.0,
    LV: 0.0,
    NL: 1.0,
    PL: 0.5489999999999999,
    PT: 0.0,
    RO: 0.6759999999999999,
    SE: 0.662,
    SI: 0.0,
    SK: 0.9309999999999999
  }.freeze

  def up
    NEW_VALUES.each do |country, new_value|
      ds = Dataset.find_by(geo_id: country)

      edit = DatasetEdit.joins(:commit)
        .where(commits: { dataset: ds }, key: 'input_industry_steel_blastfurnace_bof_share')
        .last
      edit.update(value: new_value)
      edit.save!(touch: false)
    end
  end
end
