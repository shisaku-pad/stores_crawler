require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'yoshinoya_stores.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon']

  # 下記サイトで店舗の種類「吉野家プリか」を選択し、店舗一覧を取得
  # https://stores.yoshinoya.com/yoshinoya/spot/list?c_d79=1
  PAGE_SIZE = 500
  offset = 0
  loop do
    json = `curl "https://stores.yoshinoya.com/yoshinoya/api/proxy2/shop/list?c_d79=1&c_d1=0&limit=#{PAGE_SIZE}&offset=#{offset}"`
    json = JSON.parse(json)
    raise if json["items"].empty?

    json["items"].each do |shop|
      csv << [shop["code"], "", shop["name"].delete_prefix('吉野家').strip, shop["address_name"], shop["coord"]["lat"], shop["coord"]["lon"]]
    end
    break if json["count"]["total"] <= json["count"]["offset"] + PAGE_SIZE

    offset += PAGE_SIZE
  end
end
