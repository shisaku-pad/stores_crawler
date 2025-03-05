require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'ministop_stores.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon']

  # 下記サイトで都道府県ごとに店舗一覧を取得
  # https://map.ministop.co.jp/東京都/?brands=ミニストップ
  # cisca、MINI SOFブランドは除く
  html = `curl "https://map.ministop.co.jp/all/?brands=%E3%83%9F%E3%83%8B%E3%82%B9%E3%83%88%E3%83%83%E3%83%97"`
  doc = Nokogiri::HTML.parse(html)
  json = JSON.parse(doc.at_css('script#__NEXT_DATA__').text)
  shops = json["props"]["pageProps"]["shopsData"]["shops"]
  raise if shops.empty?

  shops.each do |shop|
    next if shop["selectBrand"]["selectBrand"]["selected"]["item"]["brand"]["label"] != 'ミニストップ'

    csv << [
      shop["storeId"],
      "",
      shop["nameKanji"].delete_prefix('ミニストップ').strip,
      shop["address"],
      shop["baseInfo"]["baseInfo"]["latlng"]["latitude"],
      shop["baseInfo"]["baseInfo"]["latlng"]["longitude"]
    ]
  end
end
