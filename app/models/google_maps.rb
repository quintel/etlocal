module GoogleMaps
  DATASET_MAPS = YAML.load_file(Rails.root.join("config", "maps.yml")).freeze

  def map_image_url(size = '200x200')
    options         = DATASET_MAPS[area] || DATASET_MAPS["default"]
    options["size"] = size
    options["key"]  = Rails.configuration.google_maps_api_key

    "https://maps.googleapis.com/maps/api/staticmap?#{ options.to_query }"
  end
end
