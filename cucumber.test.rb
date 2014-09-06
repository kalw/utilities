require "rubygems"
require "watir-webdriver"
require "watir-webdriver-performance"
require "webdriver-user-agent"
require "net/http"
# Require chrome + firefox + phantomjs
# Require imagemagick system software for compairing screenshots




Given /^I want to use "(.*)" browser$/ do |device|
  case device
    when "iphone"
      @browser = Watir::Browser.new Webdriver::UserAgent.driver(:browser => :firefox, :agent => :iphone, :orientation => :portrait)
    when "ipad"
      @browser = Watir::Browser.new Webdriver::UserAgent.driver(:browser => :firefox, :agent => :ipad, :orientation => :portrait)
    when "android_phone"
      @browser = Watir::Browser.new  Webdriver::UserAgent.driver(:browser => :firefox, :agent => :android_phone, :orientation => :portrait)
    when "android_tablet"
      @browser = Watir::Browser.new  Webdriver::UserAgent.driver(:browser => :firefox, :agent => :android_tablet, :orientation => :portrait)
    when "chrome"
      @browser=Watir::Browser.new :chrome
    when "firefox"
      @browser=Watir::Browser.new :firefox
  end
  @device_useragent = @browser.execute_script('return navigator.userAgent')
end

Given /^I want to use custom headers:$/ do |headers|
  if(@browser)
    puts "Browser already defined and not compatible w/custom headers"
    logout
  end
  if(!@device_useragent)
    @device_useragent = "Mozilla/5.0"
  end
  capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs(
  "phantomjs.page.customHeaders" => headers.to_json ,
  "phantomjs.page.settings.userAgent" => @device_useragent
  )
  @browser=Watir::Browser.new :phantomjs, :desired_capabilities => capabilities
end

Given /^I go to the "(.*)" page$/ do |page|
  if(!@browser)
    @browser=Watir::Browser.new :chrome
    @browser.driver.manage.timeouts.implicit_wait=10
  end
  check_url = "#{page}"
  begin
    Timeout::timeout(20) do
      @browser.goto(check_url)
      #puts " " + (@browser.performance.summary[:response_time]/1000.0).to_s + " sec"
    end
	end
end

Then /^"(.*)" should be mentioned in the results$/ do |item|
  @browser.text.should include(item)
end

Then /^Loading time should not exeed (\d+)s$/ do |time|
	(@browser.performance.summary[:response_time]/1000.0).should <= time.to_i
end

Then /^I should not see errors$/ do
  errors = ["Call Stack", "Erreur 404", "Erreur 50", "Page Web introuvable", "Page Introuvable", "404 Not Found", "Status 404",
    "Undefined ", "Trying to", "cette page n'est pas accessible","page introuvable", "not available",
    "Warning ", "Fatal exception", "Syntax error", "Error", "Bad Gateway", "Service Unavailable", "Internal Server Error"]
  errors.each do |error|
    (@browser.html.match /error/i) == false 
  end
end

And /^I want a screenshot( named "(.*)"| of this page)?$/ do |null_item,item|
  @browser.driver.save_screenshot "screenshot_#{item}.png"
  embed "screenshot_#{item}.png", 'image/png'
end

And /^I want to take and display screenshot of this page$/ do 
  encoded_img = @browser.driver.screenshot_as(:base64)
  embed("data:image/png;base64,#{encoded_img}",'image/png')
end

Then /^I do not want more than "(.*)" diff with "(.*)" screenshot file$/ do |attended_percent_diff_number,file_to_compair|
  @browser.driver.screenshot.save("screenshot_#{item}.png")
  diff_relative_number = %x(compare #{image_1} #{image_2} -compose Difference -composite -colorspace gray -format '%[fx:mean*100]' info:)
  percentage_diff_number = 100 - diff_relative_number
  if(attended_percent_diff_number > percent_diff_number)
    %x(convert #{file_to_compair} screenshot_#{item}.png -compose difference -composite -evaluate Pow 2 -evaluate divide 3 -separate -evaluate-sequence Add -evaluate Pow 0.5 screenshot_#{item}_diff.png)
    puts 'percentage_diff_number'
    embed("data:image/png;base64,screenshot_#{item}_diff.png",'image/png')
  end
end

After do |scenario|
  #  @browser.driver.save_screenshot 'screenshot.png'
  #  embed 'screenshot.png', 'image/png'
  if(scenario.failed?)
    encoded_img = @browser.driver.screenshot_as(:base64)
    embed("data:image/png;base64,#{encoded_img}",'image/png')
    @browser.driver.save_screenshot 'screenshot_error_' + @browser.url.gsub(/^http(s)?\:\/\/(.*)$/, '\2').gsub(/[\/;\.\?]/,'') + '.last.png'
  end
  @browser.close
end

AfterStep do |scenario|
end

