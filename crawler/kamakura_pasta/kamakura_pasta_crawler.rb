require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'kamakura_pasta_shops.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon']

  json = `
    curl 'https://www.saint-marc-hd.com/api/shop/search/kamakura/' \
    -H 'accept: application/json, text/plain, */*' \
    -H 'accept-language: ja,en-US;q=0.9,en;q=0.8' \
    -H 'content-type: application/json' \
    -b '_ga=GA1.1.1339893730.1740438121; _ga_GGLGPF99GR=GS1.1.1741208758.4.1.1741208768.0.0.0; _ga_8QNTTQXDT0=GS1.1.1741208758.4.1.1741208768.0.0.0' \
    -H 'origin: https://www.saint-marc-hd.com' \
    -H 'priority: u=1, i' \
    -H 'referer: https://www.saint-marc-hd.com/kamakura/search/?br=20&o=0&t=list' \
    -H 'sec-ch-ua: "Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "macOS"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36' \
    --data-raw '{"type":"list","offset":0,"limit":10000,"brand":["20"]}'
  `
  shops = JSON.parse(json)["result"]["data"]
  raise if shops.empty?
   
  shops.each do |shop|
    csv << [
      shop["id"],
      "",
      shop["name"].delete_prefix('鎌倉パスタ').strip,
      shop["address"],
      shop["position"]["lat"],
      shop["position"]["lng"],
    ]
  end
end
