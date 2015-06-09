json.array!(@localities) do |locality|
  json.extract! locality, :id, :name, :code, :city_id
  json.url locality_url(locality, format: :json)
end
