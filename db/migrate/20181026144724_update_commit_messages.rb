class UpdateCommitMessages < ActiveRecord::Migration[5.0]
  MESSAGES = [
    [
      'Aanname Quintel',
      'Geen data beschikbaar'
    ],
    [
      'Schatting Quintel',
      'Schatting Quintel. Zie refman.energytransitionmodel.com/publications/2098 voor een overzicht van onze schattingsmethoden.'
    ],
    [
      'Quintel estimate. No 2016 data available. Estimated based on total energy/electricity/gas use reported by Klimaatmonitor and/or average data from previous years. See: https://klimaatmonitor.databank.nl/Jive?workspace_guid=7d85d44f-1169-4d6e-bec3-b0307f9296f5 And: https://klimaatmonitor.databank.nl/Jive?workspace_guid=daddc06a-6d9e-4748-b1be-c66ca6aa973c',
      'Geen data beschikbaar voor 2016. Bijschatting Quintel op basis van het totale energie-, elektriciteits- en gasgebruik in de regio (volgens Klimaatmonitor) en/of data van de afgelopen vijf jaar. Zie klimaatmonitor.databank.nl/Jive?workspace_guid=7d85d44f-1169-4d6e-bec3-b0307f9296f5 en klimaatmonitor.databank.nl/Jive?workspace_guid=daddc06a-6d9e-4748-b1be-c66ca6aa973c'
    ]
  ].freeze

  def up
    MESSAGES.each do |(was, now)|
      update_message(was, now)
    end
  end

  def down
    MESSAGES.each do |(now, was)|
      update_message(was, now)
    end
  end

  def update_message(was, now)
    commits = Commit.where(message: was)

    truncated = was
    truncated = "#{was[0..38]}..." if was.length > 40

    say_with_time("Updating #{commits.count} #{truncated.inspect} commits") do
      commits.update_all(message: now)
    end
  end
end
