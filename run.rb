require 'yaml'

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
ynab_user = YNAB::User.new(Settings.all['ynab'])
p ynab_user.import_transactions!(transactions)
