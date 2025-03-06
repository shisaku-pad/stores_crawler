require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'misterdonut_shops.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon']

  page_num = 1
  loop do
    html = `curl "https://md.mapion.co.jp/b/misterdonut/attr/?start=#{page_num}"`
    doc = Nokogiri::HTML(html)
    shops = doc.css('section ul.list li.list-item')
    raise if shops.empty?
     
    shops.each do |shop|
      csv << [
        shop.at_css('.list-content a')[:href].split("/").last,
        "",
        shop.at_css('.list-content-name').text,
        shop.at_css('.list-content-text').text,
        shop.at_css('.list-content-distance')["data-lat"],
        shop.at_css('.list-content-distance')["data-lng"],
      ]
    end
  
    break if doc.css('.pager-next ul.pager-wrap li').last["style"] == "visibility: hidden;"

    page_num += 1
  end
end
