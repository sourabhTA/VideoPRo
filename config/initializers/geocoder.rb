Geocoder.configure(
  timeout: 5,
  cache: Rails.cache,
  lookup: :google,
  api_key: ENV.fetch("google_maps_api_key")
)
