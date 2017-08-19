require 'yaml'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |f| require f }
Dir[File.join('.', 'lib/**/*.rb')].each { |f| require f }

YNAB.cleanup

ynab_user = YNAB::User.new(Settings.all['ynab'])

Settings.all['accounts'].each do |a|
  account = Account.new(a)
  account.fetch_transactions
  account.export_transactions
  ynab_user.import_transactions_to_account!(account)
end
