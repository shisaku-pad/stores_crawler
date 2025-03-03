require 'json'
require 'nokogiri'
require 'csv'

CSV.open(File.join(__dir__, 'shops.csv'), 'w') do |csv|
  csv << ['pref_id', 'shop_name', 'address', 'lat', 'lon']

  # 下記ページから都道府県ごとに店舗一覧を取得
  # https://as.chizumaru.com/famima/top?account=famima&accmd=0&arg=
  # ファミマ!!、TOMONYブランドは除く
  (1..47).map { |n| '%02d' % n }.each do |pref_id|
    html = `curl "https://as.chizumaru.com/famima/articleAddressList?account=famima&adr=#{pref_id}&c1=1"`
    doc = Nokogiri::HTML(html)
    link_elements = doc.css('#cz_mainContent .cz_part01 dd[itemprop="address"] a')
    raise if link_elements.empty?

    link_elements.each do |link_element|
      retries = 0
      url = "https://as.chizumaru.com#{link_element[:href]}&pageSize=1000"
      pp url
      list_html = `curl "#{url}"`
      list_doc = Nokogiri::HTML(list_html)
      link_elements = list_doc.css('.cz_search_result .cz_articlelist_box td.cz_display-pc-none_name a')
      raise if link_elements.empty?

      link_elements.each do |link_element|
        retries = 0
        url = "https://as.chizumaru.com#{link_element[:href]}"
        pp url
        detail_html = `curl "#{url}"`
        detail_doc = Nokogiri::HTML(detail_html)
        shop_name = detail_doc.at_css('.cz_title_box h1.cz_ttl01').text
        address_tr = detail_doc.css('.cz_display-pc-none table.cz_result_table tr').find{|tr| tr.at_css('th')&.text == '住所'}
        address = address_tr.at_css('td').text.strip

        json = JSON.parse(detail_doc.at_css('script[type="application/ld+json"]').text)
        lat = json['geo']['latitude']
        lon = json['geo']['longitude']
        csv << [pref_id, shop_name, address, lat, lon]
      rescue => e
        retries += 1
        retry if retries <= 3

        print detail_html
        puts "未知のエラーが発生しました。"
        pp e
        exit
      end
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
