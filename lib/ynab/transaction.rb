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
      @category = options.fetch(:category, nil)
      @memo = options.fetch(:memo, nil)
      @outflow = ''
      @inflow = options.fetch(:amount)

      detect_withdrawal if @cash_account_name && @is_withdrawal
    end

    def detect_withdrawal
      @payee = "Transfer : #{@cash_account_name}"
      @memo = "ATM withdrawal #{@memo}"
    end
  end
end
