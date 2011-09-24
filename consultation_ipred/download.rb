require "rubygems"
require "bundler/setup"

require 'selenium-webdriver'

driver = Selenium::WebDriver.for :firefox

["Organisations", "Public authorities"].each do |name|
  puts name
  
  driver.get "https://circabc.europa.eu/w/browse/d7497d8f-5e7e-407e-b682-71d1b71f99a5"
  wait = Selenium::WebDriver::Wait.new(:timeout => 5)

  link = wait.until {
    element = driver.find_element(:link_text => name)
    element if element.displayed?
  }
  link.click

  filename = name.downcase.gsub(/\s+/, "_") + ".links"
  File.open(filename, "w") do |file|
    
    loop do
      pdf_links = wait.until {
        driver.find_elements(:partial_link_text => ".pdf")
      }

      file.puts pdf_links.map { |link| link["href"] }.join("\n")

      begin
        next_link = driver.find_element(:css => "a[title=\"Next Page\"]")
      rescue Selenium::WebDriver::Error::NoSuchElementError
        break
      end
      next_link.click
    end
  end
end

driver.quit
