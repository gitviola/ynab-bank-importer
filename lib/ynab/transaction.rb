class YNAB
  class Transaction
    attr_reader :date, :payee, :category, :memo, :inflow, :outflow

    CASH_ACCOUNT_NAME = 'Cash'.freeze

    def initialize(options = {})
      @account_index = {}
      # build_account_index

      set_attributes(options)
    end

    def to_a
      [date.strftime('%Y-%m-%d'), payee, category, memo, outflow, inflow]
    end

    private

    def set_attributes(options = {})
      @date = options.fetch(:date)
      @payee = options.fetch(:payee)
      @category = options.fetch(:category, nil)
      @memo = options.fetch(:memo, nil)
      @outflow = ''
      @inflow = options.fetch(:amount)

      if options.fetch(:is_withdrawal, false)
        @payee = "Transfer : #{CASH_ACCOUNT_NAME}"
        @memo = "ATM withdrawal #{@memo}"
      end
    end
  end
end
