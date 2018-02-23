class Dumper
  class Fints < Dumper
    require 'ruby_fints'
    require 'digest/md5'

    def initialize(params = {})
      @ynab_id  = params.fetch('ynab_id')
      @username = params.fetch('username')
      @password = params.fetch('password')
      @iban     = params.fetch('iban')
      @endpoint = params.fetch('fints_endpoint')
      @blz      = params.fetch('fints_blz')
    end

    def fetch_transactions
      FinTS::Client.logger.level = Logger::WARN
      client = FinTS::PinTanClient.new(@blz, @username, @password, @endpoint)

      account = client.get_sepa_accounts.find { |a| a[:iban] == @iban }
      statement = client.get_statement(account, Date.today - 35, Date.today)

      statement.map { |t| to_ynab_transaction(t) }
    end

    private

    def account_id
      @ynab_id
    end

    def date(transaction)
      transaction.entry_date
    end

    def payee_name(transaction)
      parse_transaction_at(32, transaction).strip
    end

    def payee_iban(transaction)
      parse_transaction_at(31, transaction)
    end

    def memo(transaction)
      parse_transaction_at(20, transaction).strip
    end

    def amount(transaction)
      amount =
        if transaction.funds_code == 'D'
          transaction.amount
        else
          "-#{transaction.amount}"
        end

      (amount.to_f * 1000).to_i
    end

    def withdrawal?(transaction)
      memo = memo(transaction)
      return nil unless memo

      memo.include?('Atm') || memo.include?('Bargeld')
    end

    def import_id(transaction)
      data = [
        transaction_type(transaction),
        transaction.entry_date,
        transaction.amount,
        transaction.funds_code,
        transaction.reference,
        payee_iban(transaction),
        payee_name(transaction),
        @iban
      ].join

      Digest::MD5.hexdigest(data)
    end

    def transaction_type(transaction)
      # Changing the result of this method will
      # change the hash returned by the `import_id` which
      # could will result in duplicated entries.

      str = parse_transaction_at(0, transaction).encode("iso-8859-1")
                                                .force_encoding("utf-8")
      return nil unless str
      str[1..-1]
    end

    def parse_transaction_at(position, transaction)
      # I don't know who invented this structure but I hope
      # the responsible people know how inconvenient it is.

      seperator = transaction.details.seperator
      array = transaction.details.source.split("#{seperator}#{position}")
      return nil if array.size < 2

      array.last.split(seperator).first
    end

  end
end
