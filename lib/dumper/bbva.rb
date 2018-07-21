class Dumper
  # Implements logic to fetch transactions via the BBVA Spain api
  # and implements methods that convert the response to meaningful data.
  class Bbva < Dumper
    require 'bankscrap'
    require 'bankscrap-bbva'
    require 'digest/md5'

    def initialize(params = {})
      @ynab_id  = params.fetch('ynab_id')
      @username = params.fetch('username')
      @password = params.fetch('password')
      @iban     = params.fetch('iban')
    end

    def fetch_transactions
      bbva = Bankscrap::BBVA::Bank.new(user: @username, password: @password)
      account = bbva.accounts.find do |a|
        normalize_iban(a.iban) == @iban
      end

      account.transactions.map { |t| to_ynab_transaction(t) }
    end

    private

    def account_id
      @ynab_id
    end

    def date(transaction)
      transaction.effective_date
    end

    def payee_name(_transaction)
      'N/A'
    end

    def payee_iban(_transaction)
      nil
    end

    def memo(transaction)
      transaction.description
    end

    def amount(transaction)
      transaction.amount.fractional * 10
    end

    def withdrawal?(transaction)
      transaction.description.downcase.include?('cajero')
    end

    def normalize_iban(iban)
      iban.delete(' ')
    end

    def import_id(transaction)
      Digest::MD5.hexdigest(transaction.id)
    end
  end
end
