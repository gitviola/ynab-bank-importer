require 'yaml'
require 'ynab'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |f| require f }
Dir[File.join('.', 'lib/**/*.rb')].each { |f| require f }

# Gathering transactions
transactions =
  Settings.all['accounts'].map do |a|
    account = Account.new(a)
    account.fetch_transactions
    account.transactions
  end.flatten!

# Importing transactions
budget_id = Settings.all['ynab'].fetch('budget_id')
access_token = Settings.all['ynab'].fetch('access_token')

ynab_api = YNAB::API.new(access_token)
bulk_transactions = YNAB::BulkTransactions.new(transactions: transactions)

begin
  ynab_api.transactions.bulk_create_transactions(budget_id, bulk_transactions)
rescue YNAB::ApiError => e
  ErrorMessage.new(e).print
  abort
end
