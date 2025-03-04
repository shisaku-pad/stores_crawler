require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'starbacks_shops.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon']

  PAGE_SIZE = 100
  offset = 0
  loop do
    json = `curl 'https://hn8madehag.execute-api.ap-northeast-1.amazonaws.com/prd-2019-08-21/storesearch?size=#{PAGE_SIZE}&q.parser=structured&q=(and%20ver:10000%20record_type:1)&fq=(and%20data_type:%27prd%27)&sort=zip_code%20asc,store_id%20asc&start=#{offset}' \
              -H 'accept: application/json, text/plain, */*' \
              -H 'accept-language: ja-JP,ja;q=0.9,en-US;q=0.8,en;q=0.7' \
              -H 'origin: https://store.starbucks.co.jp' \
              -H 'priority: u=1, i' \
              -H 'referer: https://store.starbucks.co.jp/' \
              -H 'sec-ch-ua: "Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"' \
              -H 'sec-ch-ua-mobile: ?0' \
              -H 'sec-ch-ua-platform: "macOS"' \
              -H 'sec-fetch-dest: empty' \
              -H 'sec-fetch-mode: cors' \
              -H 'sec-fetch-site: cross-site' \
              -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36'`

    json = JSON.parse(json)["hits"]
    raise if json["hit"].empty?

    json["hit"].each do |shop|
      fields = shop["fields"]
      csv << [fields["store_id"], "", fields["name"], fields["address_5"], fields["location"].split(",").first, fields["location"].split(",").last]
    end

    break if json["found"] <= json["start"] + PAGE_SIZE

    offset += PAGE_SIZE
  end
end
