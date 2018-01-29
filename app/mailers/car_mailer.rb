class CarMailer < ActionMailer::Base
  default from: 'from@example.com'

  def new_car_email
    @car = params[:car]
    mail(to: 'flakman@mail.ru', subject: 'Новые Subaru в продаже!')
  end
end