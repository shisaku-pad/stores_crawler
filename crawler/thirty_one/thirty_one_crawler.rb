require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'thirty_one_stores.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon']

  PAGE_SIZE = 500
  offset = 0
  loop do
    json = `curl "https://store.31ice.co.jp/31ice/api/proxy2/shop/list?limit=#{PAGE_SIZE}&offset=#{offset}"`
    json = JSON.parse(json)
    raise if json["items"].empty?

    json["items"].each do |shop|
      csv << [
        shop["code"],
        "",
        shop["name"].delete_prefix('サーティワンアイスクリーム').delete_prefix('　').strip,
        shop["address_name"],
        shop["coord"]["lat"],
        shop["coord"]["lon"]
      ]
    end
    break if json["count"]["total"] <= json["count"]["offset"] + PAGE_SIZE

    offset += PAGE_SIZE
  end
end
