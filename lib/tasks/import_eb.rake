# import and encrypt eb from etdataset
namespace :energy_balance do
  desc <<-DESC
    Imports and encrypts a world energy balance from ETDataset

    Requires a DATASET and YEAR argument. Example:

    DATASET=CH_switzerland YEAR=2019

    Requires ETSource and ETDataset to be sibling directories of ETLocal
  DESC

  def encrypt_balance(directory, dataset_key)
    if File.exist?('../etsource/.password')
      password = File.read('../etsource/.password').strip
    else
      puts 'File .password not found in ETSource. Cannot encrypt energy balance CSV'
      exit(1)
    end

    csv  = directory.join('output_energy_balance_enriched.encrypted.csv')
    dest = Rails.root.join("data/datasets/energy_balance/#{dataset_key}_energy_balance_enriched.gpg")

    if csv.file?
      system("gpg --batch --yes --passphrase '#{password}' -c --output '#{dest}' '#{csv}'")
      puts '  - Encrypted energy balance'
    else
      puts "Energy balance not found at #{csv}"
    end
  end

  task import: :environment do
    directory = Pathname.new("../etdataset/data/#{ENV.fetch('DATASET')}/#{ENV.fetch('YEAR')}/energy_balance")
    encrypt_balance(directory, ENV.fetch('DATASET').split('_').first)
  end
end
