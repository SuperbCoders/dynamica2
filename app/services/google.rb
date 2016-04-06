module Dynamica::Google

  module_function

  # pass myshopify shop url
  # @return [String] google analytics site id
  def parse_site_id(shop_url)
    site_id = nil
    doc = Nokogiri::HTML(open(shop_url).read)
    ga = doc.css('script').select { |s| s.text.include? 'UA' }

    if ga.length == 1
      site_id_index = ga[0].text =~ /(UA)-(.*)-1/
      site_id = ga[0].text[site_id_index..site_id_index+12]
    end
    site_id
  end
end
