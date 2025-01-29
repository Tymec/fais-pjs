require 'nokogiri'
require "addressable/uri"
require 'httpx'
require 'pry'

require_relative '../models/product'
require_relative '../models/category'
require_relative '../models/search'

class Crawler
  URL = 'https://amazon.pl'
  HEADERS = {
    'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36',
    'Accept-Language': 'da, en-gb, en',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Referer': 'https://www.google.com/'
  }
  LIMIT = 5

  def initialize
  end

  def crawl(query, page = 1)
    url = Addressable::URI.parse(URL)
    url.path = "s"
    url.query_values = { "k" => query, "page" => page }
    
    puts "Parsing '#{url}'"
    html = _parse_page(url)

    Search.find_or_create(query: query, page: page)
    puts "Crawling results"
    _crawl_results(html)
  end

  def _crawl_results(page)
    products = page.css("div.s-search-results")
                    .css("div.s-result-item")
                    .map do |item|
      name = item.css("div[data-cy=title-recipe] a h2").first&.attr("aria-label")
      
      url_path = item.css("div[data-cy=title-recipe] a").first&.attr("href")
      url = "#{URL}#{url_path}"
      
      price_whole = item.css("span.a-price-whole").first&.text
      price_fraction = item.css("span.a-price-fraction").first&.text
      price = "#{price_whole}#{price_fraction}".gsub(/[[:space:]]/, '').to_f

      next if name.nil? || price.nil? || url.nil?
      next if name.include?("Reklama sponsorowana")

      { name: name, price: price, url: url }
    end
                    .compact

    i = 0
    products.each do |product|
      i += 1

      if i > LIMIT
        puts "Reached limit of #{LIMIT} products"
        break
      end

      puts "Crawling product #{i}/#{products.size}"

      if Product.find(name: product[:name], price: product[:price])
        puts "Product already exists: #{product[:name]}"
        next
      end
      item = Product.create(name: product[:name], price: product[:price], url: product[:url])

      details = _crawl_product(product[:url])
      category = Category.find_or_create(name: details[:category])

      item.brand = details[:brand]
      item.seller = details[:seller]
      item.category_id = category.id
      item.image = details[:image]

      if item.valid?
        item.save
        puts "Saved product: #{item.name}"
      else
        puts "Invalid product: #{item.name}"
        puts item.errors
      end

      sleep(1)
    end
  end

  def _crawl_product(url)
    puts "Parsing product '#{url}'"
    html = _parse_page(url)
    
    brand = html.css("a#bylineInfo").first&.text
    brand = brand.gsub("Odwiedź sklep", "").strip if brand
    brand = brand.gsub("Marka:", "").strip if brand

    seller = html.css("a#sellerProfileTriggerId").first&.text

    category = html.css("div#nav-subnav").first&.attr("data-category")

    image = html.css("div#imgTagWrapperId img").first&.attr("src")

    { brand: brand, seller: seller, category: category, image: image }
  end

  def _parse_page(uri)
    http = HTTPX.plugin(:follow_redirects)
                .with(headers: HEADERS)

    response = http.get(uri)
    if response.status != 200
      raise "Failed to fetch page: #{response.status}"
    end

    Nokogiri::HTML(response.body)
  end

  private :_crawl_results, :_crawl_product, :_parse_page
end
