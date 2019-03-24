class Dumper
  # Implements logic to fetch transactions via the Fints protocol
  # and implements methods that convert the response to meaningful data.
  class Fints < Dumper
    require 'ruby_fints'
    require 'digest/md5'

    def initialize(params = {})
      @ynab_id  = params.fetch('ynab_id')
      @username = params.fetch('username').to_s
      @password = params.fetch('password').to_s
      @iban     = params.fetch('iban')
      @endpoint = params.fetch('fints_endpoint')
      @blz      = params.fetch('fints_blz')
    end

    def fetch_transactions
      FinTS::Client.logger.level = Logger::WARN
      client = FinTS::PinTanClient.new(@blz, @username, @password, @endpoint)

      account = client.get_sepa_accounts.find { |a| a[:iban] == @iban }
      statement = client.get_statement(account, Date.today - 35, Date.today)

      statement.map { |t| to_ynab_transaction(t) }
    end

    private

    def account_id
      @ynab_id
    end

    def date(transaction)
      entry_date(transaction) || to_date(transaction['date'])
    end

    def payee_name(transaction)
      transaction.name.try(:strip)
    end

    def payee_iban(transaction)
      transaction.iban
    end

    def memo(transaction)
      [
        transaction.description,
        transaction.information
      ].compact.join(' / ').try(:strip)
    end

    def amount(transaction)
      (transaction.amount * transaction.sign * 1000).to_i
    end

    def withdrawal?(transaction)
      memo = memo(transaction)
      return nil unless memo

      memo.include?('Atm') || memo.include?('Bargeld')
    end

    def import_id(transaction)
      Digest::MD5.hexdigest(transaction.source)
    end

    # Patches

    # taken from https://github.com/railslove/cmxl/blob/master/lib/cmxl/field.rb
    # and modified so that it changed Feb 29th to Feb 28th on non-leap-years.
    # See issue: https://github.com/schurig/ynab-bank-importer/issues/52
    DATE = /(?<year>\d{0,2})(?<month>\d{2})(?<day>\d{2})/
    def to_date(date, year = nil)
      if match = date.to_s.match(DATE)
        year ||= "20#{match['year'] || Date.today.strftime('%y')}"
        month = match['month']
        day = match['day']

        day = '28' if !Date.leap?(year.to_i) && match['month'] == '02' && match['day'] == '29'

        Date.new(year.to_i, month.to_i, day.to_i)
      else
        date
      end
    rescue ArgumentError # let's simply ignore invalid dates
      date
    end

    def entry_date(transaction)
      data = transaction.data
      date = to_date(data['date'])

      return unless transaction.data['entry_date'] && date

      entry_date_with_date_year = to_date(data['entry_date'], date.year)
      if date.month == 1 && date.month < entry_date_with_date_year.month
        to_date(data['entry_date'], date.year - 1)
      else
        to_date(data['entry_date'], date.year)
      end
    end
  end
end
