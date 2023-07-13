require 'singleton'

class SeleniumDriver
  include Singleton

  def initialize
    @driver = create_driver
  end

  def get_driver
    @driver
  end

  private

  def create_driver
    options = Selenium::WebDriver::Options.chrome
    options.add_argument('--ignore-certificate-errors')
    options.add_argument('--incognito')
    options.add_argument('--headless')

    Selenium::WebDriver.for :chrome, options: options
  end
end
