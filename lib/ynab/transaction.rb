class YNAB
  class Transaction
    attr_reader :date, :payee, :category, :memo, :inflow, :outflow

    CASH_ACCOUNT_NAME = 'Cash'.freeze

    def initialize(options = {})
      @cash_account_name = Settings.all['ynab'].fetch('cash_account_name', nil)
      @is_withdrawal = options.fetch(:is_withdrawal, false)

      assign_attributes(options)
    end

    def to_a
      [date.strftime('%Y-%m-%d'), payee, category, memo, outflow, inflow]
    end

    private

    def assign_attributes(options = {})
      @date = options.fetch(:date)
      @payee = options.fetch(:payee)
      @payee_iban = options.fetch(:payee_iban, nil)
      @category = options.fetch(:category, nil)
      @memo = options.fetch(:memo, nil)
      @outflow = ''
      @inflow = options.fetch(:amount)

      set_withdrawal if @cash_account_name && @is_withdrawal
      detect_internal_transfer if @payee_iban
    end

    def set_withdrawal
      @payee = "Transfer : #{@cash_account_name}"
      @memo = "ATM withdrawal #{@memo}"
    end

    def detect_internal_transfer
      Settings.all['accounts'].each do |account|
        next unless account['ynab_name']
        if account['iban'] == normalize_iban(@payee_iban)
          @payee = "Transfer : #{account['ynab_name']}"
          break
        end
      end
    end

    def normalize_iban(iban)
      iban.delete(' ')
    end
  end
end
