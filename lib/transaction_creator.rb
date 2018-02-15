class TransactionCreator
  attr_accessor :account_id, :date, :amount, :payee_name, :payee_id,
                :category_name, :category_id, :memo,
                :import_id, :is_withdrawal

  class <<self
    def call(options = {})
      YNAB::Transaction.new(
        account_id: options.fetch(:account_id),
        date: options.fetch(:date),
        amount: options.fetch(:amount),
        payee_id: payee_id(options),
        payee_name: payee_name(options),
        category_id: category_id(options),
        memo: memo(options),
        import_id: options.fetch(:import_id),
        cleared: "Cleared" # TODO: shouldn't be cleared if date is in the future
      )
    end

    def payee_id(options)
      payee_id = options.fetch(:payee_id, nil)
      return payee_id if payee_id

      return cash_account_id if withdrawal?(options)

      internal_account_id = internal_account_id(options)
      internal_account_id if internal_account_id
    end

    def payee_name(options)
      return nil if payee_id(options)
      options.fetch(:payee_name, nil)
    end

    def memo(options)
      memo = options.fetch(:memo, nil)
      return "ATM withdrawal #{memo}" if withdrawal?(options)
      memo
    end

    def category_id(options)
      # Todo: query through all categories and match by category_name
      nil
    end

    # Helper methods

    def cash_account_id
      Settings.all['ynab'].fetch('cash_account_id', nil)
    end

    def withdrawal?(options)
      options.fetch(:is_withdrawal, nil)
    end

    def internal_account_id(options)
      result = Settings.all['accounts'].find do |account|
        payee_iban = payee_iban(options)
        account['ynab_id'] && payee_iban && account['iban'] == payee_iban
      end

      result['ynab_id'] if result
    end

    def payee_iban(options)
      iban = options.fetch(:payee_iban, nil)
      iban.delete(' ') if iban
    end
  end
end
