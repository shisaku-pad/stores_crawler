require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'gyukaku_shops.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon']

  html = `curl "https://map.reins.co.jp/gyukaku/map"`
  doc = Nokogiri::HTML(html)
  shops = doc.css('.result__content .store')
  raise if shops.empty?
   
  shops.each do |shop|
    csv << [
      shop['data-id'],
      "",
      shop.at_css('.store__header a.store__link .store__name').text.delete_prefix('牛角').strip,
      shop.at_css('.store__content .store__address').text,
      shop['data-lat'],
      shop['data-lon']
    ]
  end
end
