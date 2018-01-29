require 'http'
require 'rubygems'
require 'nokogiri'
require 'restclient'

class Cars
  ABW_LINK = 'https://www.abw.by/car/sell/subaru/'

  def subaru_request
    page_number = 1
    cars_list = []
    begin
      url_page = page_number == 1 ? "#{ABW_LINK}?search=1&type=1&private=1" :
                                    "#{ABW_LINK}?search=1&type=1&private=1&page=#{page_number}"
      page_body = HTTP.get(url_page)
      if page_body.status == 200
        page_parsing = Nokogiri.HTML(page_body.to_s)
        links = page_parsing.css("div.product-full-inner a.main-link")
        next_page_link = page_parsing.css("a.next")
        cars_list += links.map{ |p| p['href'].gsub(ABW_LINK,'') }
        page_number += 1
      end
    end while next_page_link.present?
    new_cars(cars_list)
  end

  def new_cars(cars_list)
    saved_cars = cars_storage.to_a
    saved_urls = saved_cars.map(&:url)
    list_new_cars = cars_list - saved_urls
    delete_cars = saved_urls - cars_list
    delete_cars.each do |url|
      archived_car = CarsStorage.where(url: url).first
      archived_car.delete
    end

    list_new_cars.each do |url|
      price, model, page, image = car_details(url)
      new_car = CarsStorage.new(url: url, status: 'N', price: price, model: model, page: page, image: image)
      if new_car.save
        # CarMailer.with(car: new_car).new_car_email.deliver_now
      end
    end
  end

  def car_details(url)
    page_body = HTTP.get("#{ABW_LINK}#{url}")
    page_parsing = Nokogiri.HTML(page_body.to_s)
    price = page_parsing.css("span.price-usd")[0].text
    model = url.split('/')[0]
    page = page_parsing.css("div.product-data")[0].text
    page += page_parsing.css("div.product-header-title")[0].text
    image_reg = page_body.to_s.match('\<meta property="og:image" content="(.*)">    <meta property')
    image = image_reg.to_s.gsub('<meta property="og:image" content="','').gsub('">    <meta property','').gsub('big','small')
    return price, model, page, image
  end

  def cars_storage
    CarsStorage.all
  end

  def parsed_info_cars
    actual_cars = cars_storage.order(updated_at: :desc)
    show_cars = []
    actual_cars.map do |actual_car|
      car_hash = {}
      elements_main = []
      elements = actual_car.page.split("\n")
      elements.each do |element|
        elements_main.push element if element.present?
      end
      car_hash[:title] = elements_main.last
      car_hash[:url] = actual_car.url
      car_hash[:price] = actual_car.price
      car_hash[:image] = actual_car.image
      elements_main.pop
      car_hash[:element] = elements_main.in_groups_of(2)
      show_cars << car_hash
    end
    show_cars
  end
#  https://motorland.by/
end