# frozen_string_literal: true

class UpdateTransportCommitMessages < ActiveRecord::Migration[5.0]
  OLD_MESSAGE = <<~MSG.gsub(/\s+/, ' ').strip
    Klimaatmonitor (2016), inclusief verbruik achter de meter. Wij rekenen het
    verbruik van ICT, treinen en elektrisch wegverkeer niet bij de
    dienstensector maar bij respectievelijk industrie en transport. URL:
    https://klimaatmonitor.databank.nl/Jive?workspace_guid=7d85d44f-1169-4d6e-bec3-b0307f9296f5
  MSG

  NEW_MESSAGE = <<~MSG.gsub(/\s+/, ' ').strip
    Klimaatmonitor (2016), inclusief verbruik mobiele werktuigen. URL:
    https://klimaatmonitor.databank.nl/Jive?workspace_guid=7d85d44f-1169-4d6e-bec3-b0307f9296f5
  MSG

  def change
    reversible do |dir|
      dir.up do
        say_with_time "Updating commits with new message" do
          commits(OLD_MESSAGE).update_all(message: NEW_MESSAGE)
        end
      end

      dir.down do
        say_with_time "Updating commits with new message" do
          commits(NEW_MESSAGE).update_all(message: OLD_MESSAGE)
        end
      end
    end
  end

  def commits(message)
    Commit.where(message: message).joins(:dataset_edits).where(
      'dataset_edits.key IN(?)',
      %w[
        input_transport_road_bio_ethanol_demand
        input_transport_road_biodiesel_demand
        input_transport_road_diesel_demand
        input_transport_road_gasoline_demand
        transport_final_demand_lpg_demand
      ]
    ).distinct
  end
end
