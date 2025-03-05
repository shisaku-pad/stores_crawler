require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'tullys_shops.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon']

  html = `curl "https://shop.tullys.co.jp/all"`
  doc = Nokogiri::HTML(html)
  shops = doc.css('.result__content .store')
  raise if shops.empty?
   
  shops.each do |shop|
    csv << [
      shop['data-id'],
      "",
      shop.at_css('.store__header a.store__link .store__name').text,
      shop.at_css('.store__content .store__address').text.strip,
      shop['data-lat'],
      shop['data-lon']
    ]
  end
end
