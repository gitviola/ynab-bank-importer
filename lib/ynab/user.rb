class YNAB
  # Has knowledge of the YNAB credentails and sends the
  # request to the API to create the transactions (bulk).
  # Will be removed as soon the official api-ruby lib is better.
  class User
    require 'httparty'
    require 'json'

    BASE_URL = 'https://api.youneedabudget.com/papi/v1'.freeze

    attr_accessor :budget_id

    def initialize(params = {})
      @access_token = params.fetch('access_token')
      @budget_id = params.fetch('budget_id')
    end

    def import_transactions!(transactions)
      HTTParty.post(
        "#{BASE_URL}/budgets/#{@budget_id}/transactions/bulk",
        headers: request_headers,
        body: { transactions: transactions }.to_json
      )
    end

    private

    def request_headers
      {
        Authorization: "Bearer #{@access_token}",
        'Content-Type' => 'application/json'
      }
    end
  end
end
