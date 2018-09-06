RSpec.describe TransactionCreator do
  describe '#call' do
    subject(:call) do
      described_class.call(
        account_id: '123456789',
        date: current_time,
        payee_name: 'Payee',
        payee_iban: 'IBAN',
        category_name: nil,
        category_id: nil,
        memo: 'Very long memo exeeding 100 characters. 12345678991234567' \
              '823456789234567893456789234567834567834567377777',
        amount: 1.1,
        is_withdrawal: false,
        import_id: '12345678'
      )
    end

    let!(:current_time) { Time.now }

    it 'creates a YNAB transaction object' do
      expect(call.instance_values).to eq(
        'account_id'  => '123456789',
        'amount'      => 1.1,
        'category_id' => nil,
        'cleared'     => 'cleared',
        'date'        => current_time,
        'flag_color'  => nil,
        'import_id'   => '12345678',
        'memo'        => 'Very long memo exeeding 100 characters. 1234567899' \
                         '12345678234567892345678934567892345678345678345673',
        'payee_id'    => nil,
        'payee_name'  => 'Payee'
      )
    end
  end
end
