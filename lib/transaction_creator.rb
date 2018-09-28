require 'ynab'

# Calculates the correct parameters for the YNAB transaction
# and build it.
class TransactionCreator
  attr_accessor :account_id, :date, :amount, :payee_name, :payee_id,
                :category_name, :category_id, :memo,
                :import_id, :is_withdrawal

  class <<self
    require 'ynab/models/save_transaction'

    # rubocop:disable Metrics/MethodLength
    def call(options = {})
      YNAB::SaveTransaction.new(
        account_id: options.fetch(:account_id),
        date: options.fetch(:date),
        amount: options.fetch(:amount),
        payee_id: payee_id(options),
        payee_name: payee_name(options),
        category_id: category_id(options),
        memo: memo(options),
        import_id: options.fetch(:import_id),
        flag_color: flag_color(options),
        cleared: 'cleared' # TODO: shouldn't be cleared if date is in the future
      )
    end
    # rubocop:enable Metrics/MethodLength

    def payee_id(options)
      payee_id = options.fetch(:payee_id, nil)
      return payee_id if payee_id

      return cash_account_id if withdrawal?(options)

      account_payee_id = account_payee_id(options)
      return account_payee_id if account_payee_id
      nil
    end

    def payee_name(options)
      return nil if payee_id(options)
      options.fetch(:payee_name, nil)
    end

    def memo(options)
      memo = options.fetch(:memo, nil)
      # The api has a limit of 100 characters for the momo field
      memo = truncate(memo, 100)
      return "ATM withdrawal #{memo}" if withdrawal?(options)
      memo
    end

    def category_id(_options)
      # TODO: query through all categories and match by category_name
      nil
    end

    # Helper methods

    def truncate(string, max)
      return nil unless string
      string.length > max ? string[0...max] : string
    end

    def cash_account_id
      Settings.all['ynab'].fetch('cash_account_id', nil)
    end

    def withdrawal?(options)
      options.fetch(:is_withdrawal, nil)
    end

    def account_payee_id(options)
      result = Settings.all['accounts'].find do |account|
        payee_iban = payee_iban(options)
        account['ynab_id'] && payee_iban && account['iban'] == payee_iban
      end

      return nil unless result
      find_payee_id_by_account_id(result['ynab_id'])
    end

    def find_payee_id_by_account_id(account_id)
      budget_id = Settings.all['ynab'].fetch('budget_id')
      access_token = Settings.all['ynab'].fetch('access_token')
      YNAB::API.new(access_token)
               .accounts
               .get_account_by_id(budget_id, account_id)
               .data.account.transfer_payee_id
    end

    def flag_color(_options)
      nil
    end

    def payee_iban(options)
      iban = options.fetch(:payee_iban, nil)
      iban.delete(' ') if iban
    end
  end
end
