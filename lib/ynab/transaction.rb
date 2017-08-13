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

      # This below

      # receiver_account = options.fetch(:receiver, nil)
      # if receiver_account && @account_index.has_key?(receiver_account)
      #   ynab_number = @account_index[receiver_account]
      #   ynab_account_name = YNAB::ACCOUNTS[ynab_number][:name]
      #   @payee = "Transfer : #{ynab_account_name}"
      # end
    end
  end
end
