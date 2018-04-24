module RemoteHelper
  module_function

  def fetch(suffix)
    JSON.parse(
      begin
        RestClient.get(
          "#{ Rails.configuration.etsource_export_root }/api/v1/etsource/#{ suffix }"
        ).body
      rescue RestClient::ExceptionWithResponse => e
        "[]"
      end
    )
  end
end
