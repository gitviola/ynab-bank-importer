class YNAB
  class Transaction
    attr_reader :account_id, :date, :amount, :payee_id, :payee_name,
                :category_id, :memo, :import_id

    def initialize(options = {})
      assign_attributes(options)
    end

    private

    def assign_attributes(options = {})
      @account_id = options.fetch(:account_id)
      @date = date(options)
      @amount = options.fetch(:amount)
      @payee_id = options.fetch(:payee_id, nil)
      @payee_name = options.fetch(:payee_name, nil)
      @category_id = options.fetch(:category_id, nil)
      @memo = options.fetch(:memo, nil)
      @import_id = options.fetch(:import_id)
      @cleared = options.fetch(:cleared)
    end

    def date(options)
      options.fetch(:date).strftime('%Y-%m-%d')
    end
  end
end
