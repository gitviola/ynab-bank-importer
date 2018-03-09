# Represents a real bank account but maps it with a YNAB account
# Uses the correct dumper to fetch the transactions.
class Account
  attr_accessor :dumper, :iban, :ynab_id, :transactions

  def initialize(params = {})
    @dumper   = Dumper.get_dumper(params.fetch('dumper'))
    @iban     = normalize_iban(params.fetch('iban'))
    @ynab_id  = params.fetch('ynab_id')

    params['iban'] = @iban # overwrite with normalized iban
    @params = params
    @transactions = nil
  end

  def fetch_transactions
    dumper = @dumper.new(@params)
    @transactions = dumper.fetch_transactions.compact
  end

  private

  def normalize_iban(iban)
    iban.delete(' ')
  end
end
