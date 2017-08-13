module Helpers
  class SeleniumHelper
    require 'selenium-webdriver'

    # There is an issue with chrome, the setting for the download_path
    # doesn't work. That's why this is set to the default download path.
    DOWNLOAD_DIR = "#{Dir.home}/Downloads".freeze

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
