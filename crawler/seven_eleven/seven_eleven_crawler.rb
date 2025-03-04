require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'seven_eleven_stores.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon']

  # 下記サイトで店舗の種類「セブンイレブン」を選択し、店舗一覧を取得
  # https://map.omni7.jp/7andimap/spot/list
  PAGE_SIZE = 500
  offset = 0
  loop do
    json = `curl "https://map.omni7.jp/7andimap/api/proxy2/shop/list?category=01&limit=#{PAGE_SIZE}&offset=#{offset}"`
    json = JSON.parse(json)
    raise if json["items"].empty?

    json["items"].each do |shop|
      csv << [shop["code"], "", "#{shop["name"]}店", shop["address_name"], shop["coord"]["lat"], shop["coord"]["lon"]]
    end
    break if json["count"]["total"] <= json["count"]["offset"] + PAGE_SIZE

    offset += PAGE_SIZE
  end
end
