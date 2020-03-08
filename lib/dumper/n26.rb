class Dumper
  # Implements logic to fetch transactions via the N26 api
  # and implements methods that convert the response to meaningful data.
  class N26 < Dumper
    require 'twentysix'
    require 'active_support'
    require 'digest/md5'

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
      @skip_pending_transactions = params.fetch('skip_pending_transactions',
                                                false)
      @categories = {}
    end

    def fetch_transactions
      client = TwentySix::Core.authenticate(@username, @password)
      check_authorization!(client)
      client.categories.map do |category|
        @categories[category['id']] = category['name']
      end

      client.transactions(count: 100)
            .select { |t| accept?(t) }
            .map { |t| to_ynab_transaction(t) }
    end

    def accept?(transaction)
      return true unless @skip_pending_transactions
      already_processed?(transaction)
    end

    private

    def check_authorization!(client)
      return if client.instance_variable_get('@access_token')
      raise "Couldn't login with your provided N26 credentials. " \
            "Please verify that they're correct."
    end

    def account_id
      @ynab_id
    end

    def date(transaction)
      timestamp = Time.at(transaction['visibleTS'] / 1000)
      Date.parse(timestamp.strftime('%Y-%m-%d'))
    end

    def payee_name(transaction)
      [
        transaction['merchantName'],
        transaction['partnerName']
      ].join(' ').try(:strip)
    end

    def payee_iban(transaction)
      transaction['partnerIban']
    end

    def category_name(transaction)
      return nil unless @set_category
      @categories[transaction['category']]
    end

    def memo(transaction)
      [
        transaction['referenceText'],
        transaction['merchantCity']
      ].join(' ').try(:strip)
    end

    def amount(transaction)
      (transaction['amount'].to_f * 1000).to_i
    end

    def withdrawal?(transaction)
      WITHDRAWAL_CATEGORIES.include?(transaction['category'])
    end

    def cleared?(transaction)
      already_processed?(transaction)
    end

    def import_id(transaction)
      data = [transaction['visibleTS'],
              transaction['transactionNature'],
              transaction['amount'],
              transaction['accountId']].join

      Digest::MD5.hexdigest(data)
    end

    # All very recent transactions with the credit card have
    # the type value set to "AA". So we assume that this is an
    # indicator to check if a transaction has been processed or not.
    def already_processed?(transaction)
      transaction['type'] != 'AA'
    end
  end
end
