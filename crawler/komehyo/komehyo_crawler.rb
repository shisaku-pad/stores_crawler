require 'json'
require 'nokogiri'
require 'csv'

CSV.open('shops.csv', 'w') do |csv|
  csv << ['Prefecture', 'Shop Name', 'Address']

  ['北海道','青森県','岩手県','宮城県','秋田県','山形県','福島県','茨城県','栃木県','群馬県','埼玉県','千葉県','東京都','神奈川県','山梨県','長野県','新潟県','富山県','石川県','福井県','岐阜県','静岡県','愛知県','三重県','滋賀県','京都府','大阪府','兵庫県','奈良県','和歌山県','鳥取県','島根県','岡山県','広島県','山口県','徳島県','香川県','愛媛県','高知県','福岡県','佐賀県','長崎県','熊本県','大分県','宮崎県','鹿児島県','沖縄県'].each do |pref|
    html = `/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome --headless --disable-gpu --dump-dom https://komehyo.jp/kaitori/shop/#{pref}`
    doc = Nokogiri::HTML(html)
    link_elements = doc.css('.search-detail-section .search-detail-box')
    
    link_elements.each do |link_element|
      shop_name = link_element.at_css('h3.search-detail-title').text
      # ここでKOMEHYO消すべきかは要調整
      shop_name = shop_name.sub(/^\d+KOMEHYO/, '').strip
      address = link_element.at_css('p.search-detail-address').text
      address = address.sub(/^〒\d{3}-\d{4}/, '').strip
      pp pref, shop_name, address
      csv << [pref, shop_name, address]
    end
  end
end
