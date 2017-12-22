class Dumper
  class FintsDkb < Dumper
    require 'ruby_fints'

    ENDPOINT  = 'https://banking-dkb.s-fints-pt-dkb.de/fints30'.freeze
    BLZ       = '12030000'.freeze
    SEPERATOR = '?'.freeze

    def initialize(params = {})
      @username = params.fetch('username')
      @password = params.fetch('password')
      @iban     = params.fetch('iban')
    end

    def fetch_transactions
      FinTS::Client.logger.level = Logger::WARN
      client = FinTS::PinTanClient.new(BLZ, @username, @password, ENDPOINT)

      account = client.get_sepa_accounts.find { |a| a[:iban] == @iban }
      statement = client.get_statement(account, Date.today - 35, Date.today)

      statement.map { |t| to_ynab_format(t) }
    end

    private

    def to_ynab_format(transaction)
      YNAB::Transaction.new(
        date: transaction.date,
        payee: parse_transaction_at(32, transaction),
        payee_iban: parse_transaction_at(31, transaction),
        category: nil,
        memo: parse_transaction_at(20, transaction),
        amount: amount(transaction),
        is_withdrawal: withdrawal?(transaction)
      )
    end

    def parse_transaction_at(position, transaction)
      # I don't know who invented this structure but I hope
      # the responsible people know how inconvenient it is.
      array = transaction.details.source.split("#{SEPERATOR}#{position}")
      return nil if array.size < 2

      array.last.split(SEPERATOR).first
    end

    def amount(transaction)
      return "-#{transaction.amount}" if transaction.funds_code == 'D'
      transaction.amount.to_s
    end

    def withdrawal?(transaction)
      memo = parse_transaction_at(20, transaction)
      return nil unless memo

      memo.include?('Atm') || memo.include?('Bargeld')
    end
  end
end
