class YNAB
  class User
    require 'selenium-webdriver'

    LOGIN_PAGE = 'https://app.youneedabudget.com/users/login'.freeze

    attr_accessor :username, :password, :budget_id

    def initialize(params = {})
      @username = params.fetch('username')
      @password = params.fetch('password')
      @budget_id = params.fetch('budget_id')
    end

    def import_transactions_to_account!(account)
      return unless File.exist?(account.export_file)

      selenium = Helpers::SeleniumHelper.new
      webdriver = selenium.webdriver

      login(webdriver)

      webdriver.get "https://app.youneedabudget.com/#{budget_id}/accounts/#{account.ynab_id}"
      wait = Selenium::WebDriver::Wait.new(timeout: 15)
      import_icon = wait.until do
        element = webdriver.find_element(:class_name, 'accounts-toolbar-file-import-transactions')
        element if element.displayed?
      end
      import_icon.click

      wait = Selenium::WebDriver::Wait.new(timeout: 15)
      file_input = wait.until do
        webdriver.find_element(:xpath, "//input[@type='file']")
      end
      file_input.send_keys account.export_file

      puts File.exist?(account.export_file).inspect
      puts "Uploading #{account.export_file}"

      sleep 2

      wait = Selenium::WebDriver::Wait.new(timeout: 5)
      wait.until do
        element = webdriver.find_element(:class_name, 'modal-import-review')
        element if element.displayed?
      end

      try_submit_click(webdriver)
      try_submit_click(webdriver)

      selenium.stop
    end

    private

    def login(webdriver)
      webdriver.get LOGIN_PAGE
      sleep 1

      form_username = webdriver.find_element(class_name: 'login-username')
      form_username.send_keys @username
      form_password = webdriver.find_element(class_name: 'login-password')
      form_password.send_keys @password
      submit_button = webdriver.find_element(class_name: 'button-primary')
      submit_button.click

      wait = Selenium::WebDriver::Wait.new(timeout: 15)
      wait.until { webdriver.current_url.include?(@budget_id) }
    end

    def try_submit_click(webdriver)
      wait = Selenium::WebDriver::Wait.new(timeout: 15)
      submit_button = wait.until do
        element = webdriver.find_element(:class_name, 'button-primary')
        element if element.displayed?
      end

      submit_button.click if submit_button.enabled?
      sleep 1
    end
  end
end
