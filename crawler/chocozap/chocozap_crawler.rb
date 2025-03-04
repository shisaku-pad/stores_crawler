require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'chocozap_shops.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon']

  ['北海道','青森県','岩手県','宮城県','秋田県','山形県','福島県','茨城県','栃木県','群馬県','埼玉県','千葉県','東京都','神奈川県','山梨県','長野県','新潟県','富山県','石川県','福井県','岐阜県','静岡県','愛知県','三重県','滋賀県','京都府','大阪府','兵庫県','奈良県','和歌山県','鳥取県','島根県','岡山県','広島県','山口県','徳島県','香川県','愛媛県','高知県','福岡県','佐賀県','長崎県','熊本県','大分県','宮崎県','鹿児島県','沖縄県'].each do |pref|
    page_num = 1
    loop do
      json = `curl "https://chocozap.g.kuroco.app/rcms-api/34/studios?filter=keyword%20icontains%20%22#{pref}%22&pageID=#{page_num}"`
      json = JSON.parse(json)
      break if !json["errors"].empty? && json["errors"][0]["message"] == "pageID is too big."
      raise if json["list"].empty?

      json["list"].each do |shop|
        csv << [
          shop["hacomono_studio_id"],
          pref,
          "#{shop["name"]}店",
          shop["address"],
          shop["coords"]["gmap_y"],
          shop["coords"]["gmap_x"]
        ]
      end
      page_num += 1
    end
  end
end
