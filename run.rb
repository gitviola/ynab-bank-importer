require 'yaml'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |f| require f }
Dir[File.join('.', 'lib/**/*.rb')].each { |f| require f }
config = YAML.load_file('config.yml')

YNAB.cleanup

ynab_user = YNAB::User.new(config['ynab'])

config['accounts'].each do |a|
  account = Account.new(a)
  account.fetch_transactions
  account.export_transactions
  ynab_user.import_transactions_to_account!(account)
end
