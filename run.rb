require 'yaml'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |f| require f }
Dir[File.join('.', 'lib/**/*.rb')].each { |f| require f }

ynab_user = YNAB::User.new(Settings.all['ynab'])

Settings.all['accounts'].each do |a|
  account = Account.new(a)
  account.fetch_transactions
  ynab_user.import_transactions!(account.transactions)
end
