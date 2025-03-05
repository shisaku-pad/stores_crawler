require 'json'
require 'nokogiri'
require 'csv'

CATEGORY_IDS = [
  "0101", # ガスト
  "0102", # バーミヤン
  "0119", # しゃぶ葉
  "0103", # ジョナサン
  "0104", # 夢庵
  "0105", # ステーキガスト
  "0117", # から好し（ガスト内店含む）
  "0106", # グラッチェガーデンズ
  "0107", # 藍屋
  "0201", # むさしの森珈琲
  "0109", # 魚屋路
  "0110", # chawan
  "0206", # ラ・オハナ
  "0114", # とんから亭
  "0120", # 桃菜
  "0123", # 包包點心
  "0122", # 點心甜心
  "0112", # ゆめあん食堂
  "0121", # 八郎そば
  "0111", # 三〇三
]
today = Date.today

CSV.open(File.join(__dir__, 'skylark_stores.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon', 'brand', 'is_deleted']

  json = `curl "https://store-info.skylark.co.jp/api/point/?backend_filters=%257B%257D&backend_order=%257B%257D"`
  json = JSON.parse(json)
  raise if json["items"].empty?

  json["items"].each do |shop|
    open_date = shop["extra_fields"]["開店日データ"]
    next unless CATEGORY_IDS.include?(shop["marker"]["ja"]["id"])
    next if Date.parse(open_date) > today

    brand = shop["marker"]["ja"]["name"]
    brand = brand == 'から好し（ガスト内店含む）' ? 'から好し' : brand
    csv << [shop["id"], "", shop["name"].delete_prefix(brand).strip, shop["address"].delete_suffix('　'), shop["latitude"], shop["longitude"], brand, shop["extra_fields"]["削除フラグ"]]
  end
end
