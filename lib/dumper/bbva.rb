class Dumper
  class Bbva < Dumper
    require 'bankscrap'
    require 'bankscrap-bbva'

    def initialize(params = {})
      @username = params.fetch('username')
      @password = params.fetch('password')
      @iban     = params.fetch('iban')
    end

    def fetch_transactions
      bbva = Bankscrap::BBVA::Bank.new(user: @username, password: @password)
      account = bbva.accounts.find do |a|
        normalize_iban(a.iban) == @iban
      end

      account.transactions.map { |t| to_ynab_format(t) }
    end

    private

    def to_ynab_format(transaction)
      YNAB::Transaction.new(
        date: transaction.effective_date,
        payee: 'N/A',
        memo: transaction.description,
        amount: transaction.amount
      )
    end

    def normalize_iban(iban)
      iban.delete(' ')
    end
  end
end
