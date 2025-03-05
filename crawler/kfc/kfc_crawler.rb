require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'kfc_stores.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon']

  json = `curl "https://search.kfc.co.jp/api/point"`
  json = JSON.parse(json)
  raise if json["items"].empty?

  json["items"].each do |shop|
    csv << [shop["key"], "", shop["name"], shop["address"], shop["latitude"], shop["longitude"]]
  end
end
