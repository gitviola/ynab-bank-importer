class Account
  attr_accessor :dumper, :iban, :ynab_id, :csv_file

  def initialize(params = {})
    @dumper   = Dumper.get_dumper(params.fetch('dumper'))
    @iban     = normalize_iban(params.fetch('iban'))
    @ynab_id  = params.fetch('ynab_id')

    params['iban'] = @iban
    @params = params
    @transactions = nil
  end

  def fetch_transactions
    dumper = @dumper.new(@params)
    @transactions = dumper.fetch_transactions
  end

  def export_transactions
    raise 'You need to call `fetch_transactions` first' if @transactions.nil?
    return if @transactions.empty?

    FileUtils.mkdir_p YNAB::EXPORT_DIR
    CSV.open(export_file, 'wb') do |csv|
      csv << %w[Date Payee Category Memo Outflow Inflow]
      @transactions.each { |transaction| csv << transaction.to_a }
    end
  end

  def export_file
    "#{YNAB::EXPORT_DIR}/#{@iban}.csv"
  end

  private

  def normalize_iban(iban)
    iban.delete(' ')
  end
end
