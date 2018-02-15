class Dumper
  class N26 < Dumper
    require 'twentysix'

    WITHDRAWAL_CATEGORIES = [
      'micro-v2-atm',
      'micro-v2-cash26'
    ].freeze

    def initialize(params = {})
      @ynab_id  = params.fetch('ynab_id')
      @username = params.fetch('username')
      @password = params.fetch('password')
      @iban     = params.fetch('iban')
      @set_category = params.fetch('set_category', false)
      @categories = {}
    end

    def fetch_transactions
      client = TwentySix::Core.authenticate(@username, @password)
      client.categories.map do |category|
        @categories[category['id']] = category['name']
      end

      client.transactions(count: 100).map { |t| to_ynab_transaction(t) }
    end

    private

    def account_id
      @ynab_id
    end

    def date(transaction)
      string_date = Time.at(transaction['visibleTS'] / 1000).strftime('%Y-%m-%d')
      Date.parse(string_date)
    end

    def payee_name(transaction)
      [transaction['merchantName'], transaction['partnerName']].join(' ').strip
    end

    def payee_iban(transaction)
      nil
    end

    def category_name(transaction)
      return nil unless @set_category
      @categories[transaction['category']]
    end

    def memo(transaction)
      [transaction['referenceText'], transaction['merchantCity']].join(' ').strip
    end

    def amount(transaction)
      transaction['amount'].to_i * 1000
    end

    def withdrawal?(transaction)
      WITHDRAWAL_CATEGORIES.include?(transaction['category'])
    end

    def import_id(transaction)
      transaction['id']
    end
  end
end
