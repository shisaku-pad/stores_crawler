require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'family_mart_shops.csv'), 'w') do |csv|
  csv << ['store_id', 'pref_id', 'shop_name', 'address', 'lat', 'lon']

  # 下記ページから都道府県ごとに店舗一覧を取得
  # https://as.chizumaru.com/famima/articleList?c1=1&c2=1%2c2&account=famima&pageSize=100&bpref=01&pg=1
  # ファミマ!!、TOMONYブランドは除く
  (1..47).map { |n| '%02d' % n }.each do |pref_id|
    page_num = 1
    loop do
      retries = 0
      puts "pref_id: #{pref_id}"
      puts "page_num: #{page_num}"
      list_html = `curl "https://as.chizumaru.com/famima/articleList?c1=1&c2=1%2c2&account=famima&bpref=#{pref_id}&pageSize=10&pg=#{page_num}"`
      list_doc = Nokogiri::HTML(list_html)
      link_elements = list_doc.css('.cz_articlelist_box a.cz_btn_detail')
      raise if link_elements.empty?
  
      link_elements.each do |link_element|
        retries = 0
        url = "https://as.chizumaru.com#{link_element[:href]}"
        bid = url.match(/bid=(\d+)/)&.captures&.first
        detail_html = `curl "#{url}"`
        detail_doc = Nokogiri::HTML(detail_html)
        shop_name = detail_doc.at_css('.cz_title_box h1.cz_ttl01').text
        address_tr = detail_doc.css('.cz_display-pc-none table.cz_result_table tr').find{|tr| tr.at_css('th')&.text == '住所'}
        address = address_tr.at_css('td').text.strip
  
        json = JSON.parse(detail_doc.at_css('script[type="application/ld+json"]').text)
        lat = json['geo']['latitude']
        lon = json['geo']['longitude']
        pp [bid, pref_id, shop_name, address, lat, lon]
        csv << [bid, pref_id, shop_name, address, lat, lon]
      rescue => e
        retries += 1
        retry if retries <= 3
  
        print detail_html
        puts "未知のエラーが発生しました。"
        pp e
        exit
      end
      break if list_doc.css('.cz_top_box .cz_nav').last.text != '次へ'

      page_num += 1
    rescue => e
      retries += 1
      retry if retries <= 3

      print list_html
      puts "未知のエラーが発生しました。"
      pp e
      exit
    end
  end
end
