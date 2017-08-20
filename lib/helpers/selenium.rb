module Helpers
  class SeleniumHelper
    require 'selenium-webdriver'
    DOWNLOAD_DIR = '/usr/app/.cache'.freeze

    attr_reader :webdriver

    def initialize
      @webdriver ||= start_browser
    end

    def stop
      @webdriver.quit
    end

    private

    def start_browser
      # runs in docker container or on local machine?
      if ENV['WEBDRIVER_URL']
        Selenium::WebDriver.for :remote, desired_capabilities: :chrome, url: ENV['WEBDRIVER_URL']
      else
        prefs = {
          prompt_for_download: false,
          default_directory: @download_dir,
          downloads_path: @download_dir,
          directoy: @download_dir
        }
        options = Selenium::WebDriver::Chrome::Options.new
        options.add_preference(:download, prefs)
        options.add_argument('--disable-translate')

        Selenium::WebDriver.for :chrome, options: options
      end
    end
  end
end
