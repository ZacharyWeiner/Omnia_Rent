json.array!(@cities) do |city|
  json.extract! city, :id, :name, :code
  json.url city_url(city, format: :json)
end
