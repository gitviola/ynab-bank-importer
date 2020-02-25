class Dumper
  class SaltEdge < Dumper
    require 'digest/md5'
    require 'rest-client'
    require 'json'

    WITHDRAWAL_CATEGORIES = [
      'micro-v2-atm',
      'micro-v2-cash26'
    ].freeze


    def initialize(params = {})

      @merchant_lookup = {}
      @ynab_id  = params.fetch('ynab_id')
      @saltedge_app_id = params.fetch('saltedge_app_id')
      @saltedge_secret = params.fetch('saltedge_secret')
      @saltedge_connection_id = params.fetch('saltedge_connection_id')
      @saltedge_account_id = params.fetch('saltedge_account_id')
      @saltedge_transaction_count = params.fetch('saltedge_transaction_count')
      @iban = params.fetch('iban')
    end

    def request(method, url, params={}, payload={})

      RestClient::Request.execute(
        method:  method,
        url:     url,
        payload: payload,
        log:     Logger.new(STDOUT),
        headers: {
          "Accept"       => "application/json",
          "Content-type" => "application/json",
          :params => params,
          "App-Id"       => @saltedge_app_id,
          "Secret"       => @saltedge_secret
        }
      )
    rescue RestClient::Exception => error
      pp JSON.parse(error.response)
    end

    def fetch_transactions

      data = request(:get, "https://www.saltedge.com/api/v5/transactions",
        {
          :connection_id => @saltedge_connection_id,
          :account_id => @saltedge_account_id,
          :per_page => @saltedge_transaction_count
        })

      transactions = JSON.parse(data.body)['data']

      merchants = Set[]

      transactions.each do |t|
        merchants.add(t['extra']['merchant_id'])
      end

      merchants_details = request(:post, "https://www.saltedge.com/api/v4/merchants",
        {
          :connection_id => @saltedge_connection_id,
          :account_id => @saltedge_account_id,
          :per_page => @saltedge_transaction_count
        }, '{"data": ' + merchants.to_json + '}')


      merchants_result = JSON.parse(merchants_details.body)['data']

      merchants_result.each do |t|
        @merchant_lookup[t['id']] = t['names'][0]['value']
      end

      transactions.select { |t| accept?(t) }
            .map { |t| to_ynab_transaction(t) }
    end

    def accept?(transaction)
      return transaction['status'] == 'posted'
    end

    private

    def account_id
      @ynab_id
    end

    def date(transaction)
      Date.parse(transaction['made_on'])
    end

    def payee_name(transaction)
      merchant_id = transaction['extra']['merchant_id']
      @merchant_lookup[merchant_id].try(:strip)

    end

    def payee_iban(transaction)
      return nil
    end

    def category_name(transaction)
      return nil
    end

    def memo(transaction)
      [
        transaction['description'],
      ].join(' ').try(:strip)
    end

    def amount(transaction)
      (transaction['amount'].to_f * 1000).to_i
    end

    def withdrawal?(transaction)
      WITHDRAWAL_CATEGORIES.include?(transaction['category'])
    end

    def import_id(transaction)
      data = [transaction['id'],
              transaction['account_id'],
              transaction['amount'],
              transaction['description']].join

      Digest::MD5.hexdigest(data)
    end

  end
end
