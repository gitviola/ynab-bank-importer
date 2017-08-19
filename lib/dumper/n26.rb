class Dumper
  class N26 < Dumper
    require 'twentysix'

    WITHDRAWAL_CATEGORIES = [
      'micro-v2-atm',
      'micro-v2-cash26'
    ].freeze

    def initialize(params = {})
      @username = params.fetch(:username)
      @password = params.fetch(:password)
      @iban     = params.fetch(:iban)
      @set_category = params.fetch(:set_category, false)
      @categories = {}
    end

    def fetch_transactions
      client = TwentySix::Core.authenticate(@username, @password)
      client.categories.map do |category|
        @categories[category['id']] = category['name']
      end

      client.transactions(count: 100).map { |t| to_ynab_format(t) }
    end

    private

    def to_ynab_format(transaction)
      YNAB::Transaction.new(
        date: to_date(transaction['visibleTS']),
        payee: [transaction['merchantName'], transaction['partnerName']].join(' ').strip,
        category: transaction_category(transaction),
        memo: [transaction['referenceText'], transaction['merchantCity']].join(' ').strip,
        amount: transaction['amount'],
        is_withdrawal: WITHDRAWAL_CATEGORIES.include?(transaction['category'])
      )
    end

    def normalize_iban(iban)
      iban.delete(' ')
    end

    def to_date(string)
      string_date = Time.at(string / 1000).strftime('%Y-%m-%d')
      Date.parse(string_date)
    end

    def transaction_category(transaction)
      nil unless @set_category
      @categories[transaction['category']]
    end
  end
end
