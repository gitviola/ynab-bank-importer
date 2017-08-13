class Dumper
  class Figo < Dumper
    require 'selenium-webdriver'
    require 'base32'
    require 'fileutils'

    WEBSITE = 'https://home.figo.me'.freeze

    def initialize(params = {})
      @username = params.fetch(:username)
      @password = params.fetch(:password)
      @iban     = params.fetch(:iban)
      @force_download = params.fetch(:force_download, false)
    end

    def fetch_transactions
      download_csv_file if !File.exist?(cache_file) || @force_download
      transactions = []

      CSV.foreach(File.path(cache_file), headers: true) do |row|
        account_number = row[3]

        # last 10 degets of german ibans are the account number
        if account_number == @iban.last(10)
          transaction = to_ynab_format(row)
          transactions.push(transaction)
        end
      end

      transactions
    end

    private

    def to_ynab_format(transaction)
      YNAB::Transaction.new(
        date: Date.parse(transaction[0]),
        payee: transaction[6],
        category: nil,
        memo: transaction[11],
        amount: transaction[13],
        is_withdrawal: withdrawal?(transaction),
        receiver: transaction[7]
      )
    end

    def withdrawal?(transaction)
      transaction[10] == 'Direct debit' && (
        transaction[6].include?('Atm') ||
        transaction[11].include?('Bargeld')
      )
    end

    def cache_file
      encoded = Base32.encode(@username)
      "#{YNAB::CACHE_DIR}/#{encoded}.csv"
    end

    def download_csv_file
      selenium = Helpers::SeleniumHelper.new
      webdriver = selenium.webdriver

      webdriver.navigate.to WEBSITE

      form_username = webdriver.find_element(id: 'id_username')
      form_username.send_keys @username
      form_password = webdriver.find_element(id: 'id_password')
      form_password.send_keys @password
      form_password.submit

      wait = Selenium::WebDriver::Wait.new(timeout: 30)
      wait.until { webdriver.execute_script('return window.location.pathname') == '/transactions' }
      webdriver.get "#{WEBSITE}/export/transactions?format=csv&account_id=&filter="

      sleep 2

      webdriver.navigate.to WEBSITE
      selenium.stop

      FileUtils.mkdir_p YNAB::CACHE_DIR
      FileUtils.mv("#{Helpers::SeleniumHelper::DOWNLOAD_DIR}/transactions.csv", cache_file)
    end
  end
end
