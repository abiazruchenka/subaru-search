class MainController < ApplicationController
  def index
    cars = Cars.new
    @storage_cars = cars.parsed_info_cars
  end

  def abw_request
    cars = Cars.new
    cars.subaru_request
    redirect_to main_index_path
  end
end