require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'ministop_stores.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon']

  # 下記サイトで都道府県ごとに店舗一覧を取得
  # https://map.ministop.co.jp/東京都/?brands=ミニストップ
  # cisca、MINI SOFブランドは除く
  ['北海道','青森県','岩手県','宮城県','秋田県','山形県','福島県','茨城県','栃木県','群馬県','埼玉県','千葉県','東京都','神奈川県','山梨県','長野県','新潟県','富山県','石川県','福井県','岐阜県','静岡県','愛知県','三重県','滋賀県','京都府','大阪府','兵庫県','奈良県','和歌山県','鳥取県','島根県','岡山県','広島県','山口県','徳島県','香川県','愛媛県','高知県','福岡県','佐賀県','長崎県','熊本県','大分県','宮崎県','鹿児島県','沖縄県'].each do |pref|
    json = `curl "https://map.ministop.co.jp/_next/data/P8GityetTV3PGIh79psyN/#{pref}.json?brands=ミニストップ"`
    json = JSON.parse(json)["pageProps"]
    next if json["status"] == 404

    shops = json["shopsData"]["shops"]
    raise if shops.empty?

    shops.each do |shop|
      next if shop["selectBrand"]["selectBrand"]["selected"]["item"]["brand"]["label"] != 'ミニストップ'

      csv << [
        shop["storeId"],
        pref,
        shop["nameKanji"].delete_prefix('ミニストップ').strip,
        shop["address"],
        shop["baseInfo"]["baseInfo"]["latlng"]["latitude"],
        shop["baseInfo"]["baseInfo"]["latlng"]["longitude"]
      ]
    end
  end
end
