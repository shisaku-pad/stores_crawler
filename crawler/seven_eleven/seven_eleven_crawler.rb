require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'seven_eleven_stores.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon']

  # 下記サイトで店舗の種類「セブンイレブン」を選択し、都道府県ごとに店舗一覧を取得
  # https://map.omni7.jp/7andimap/
  (1..47).map { |n| '%02d' % n }.each do |pref_id|
    offset = 0
    loop do
      json = `curl "https://map.omni7.jp/7andimap/api/proxy2/shop/list?category=01&address=#{pref_id}&limit=500&offset=#{offset}"`
      json = JSON.parse(json)
      json["items"].each do |shop|
        csv << [shop["code"], pref_id, "#{shop["name"]}店", shop["address_name"], shop["coord"]["lat"], shop["coord"]["lon"]]
      end
      break if json["items"].empty? && json["count"]["total"] <= json["count"]["offset"]

      offset += 500
    end
  end
end
