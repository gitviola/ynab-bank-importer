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
      @categories = {}
    end

    def fetch_transactions
      client = TwentySix::Core.authenticate(@username, @password)
      client.categories.map do |category|
        @categories[category['id']] = category['name']
      end

      # to = Time.now.to_i
      # from = to - 86_400 * 8

      client.transactions(count: 100)
            .reject { |t| t['pending'] } # Only transactions that aren't pending
            .map { |t| to_ynab_transaction(t) }
    end

    private

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

    def import_id(transaction)
      data = [calculated_timestamp(transaction),
              transaction['transactionNature'],
              transaction['amount'],
              transaction['accountId']].join

      Digest::MD5.hexdigest(data)
    end

    # N26 seems to have an internal timezone mismatch in their database
    # transactions that are not processed yet have the `visibleTS` value
    # in UTC but processed transactions have timezone Europe/Berlin.
    # => This method checks if the transaction was processed or not.
    #    If it's already processed it will just take the time, if not if will
    #    add the current offset to make it Europe/Berlin timezone.
    def calculated_timestamp(transaction)
      return transaction['visibleTS'] if alread_processed?(transaction)
      offset_to_utc = Time.now.in_time_zone('Europe/Berlin').utc_offset
      transaction['visibleTS'] / 1000 + offset_to_utc
    end

    # All very recent transactions with the credit card have
    # the type value set to "AA". So we assume that this is an
    # indicator to check if a transactions has been processed or not.
    def alread_processed?(transaction)
      transaction['type'] != 'AA'
    end
  end
end
