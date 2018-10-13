RSpec.describe TransactionCreator do
  VCR_OPTIONS = { match_requests_on: %i[method host path] }.freeze

  describe '.call' do
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

  describe '.payee_id' do
    subject(:method) { described_class.payee_id(options) }

    let(:payee_id) { nil }
    let(:options) { { payee_id: payee_id } }

    context 'when payee_id is set' do
      let(:payee_id) { '12345678' }

      it 'returns that payee_id' do
        expect(method).to eq(payee_id)
      end
    end

    context 'when transaction is a withdrawal?' do
      let(:expected_account_id) { 'ebec22d4-1905-11e8-8a4c-7b32b5a7e49f' }

      before do
        allow(described_class).to receive(:withdrawal?).and_return(true)
        allow(described_class).to(
          receive(:find_payee_id_by_account_id)
          .and_return(expected_account_id)
        )
      end

      it 'returns the payee_id of the cash account' do
        expect(method).to eq(expected_account_id)
      end
    end

    context 'when transaction is an internal transfer' do
      before do
        allow(described_class).to receive(:account_payee_id)
          .and_return('12345')
      end

      it 'returns that payee_id' do
        expect(method).to eq('12345')
      end
    end

    context 'when nothing relevant is set' do
      it 'returns nil' do
        expect(method).to be_nil
      end
    end
  end

  describe '.account_payee_id' do
    subject(:method) { described_class.account_payee_id(options) }

    let(:options) { { payee_iban: payee_iban } }

    context 'when the transfer is an internal transfer' do
      let(:payee_iban) { 'DE89370400440532013000' }
      let(:expected_account_id) { 'ebec22d4-1905-11e8-8a4c-7b32b5a7e49f' }

      before do
        allow(described_class).to(
          receive(:find_payee_id_by_account_id)
          .and_return(expected_account_id)
        )
      end

      it 'returns the correct account id' do
        expect(method).to eq(expected_account_id)
      end
    end

    context 'when the transfer is NO internal transfer' do
      let(:payee_iban) { nil }

      it 'returns the correct account id' do
        expect(method).to be_nil
      end
    end
  end

  describe '.find_payee_id_by_account_id', vcr: VCR_OPTIONS do
    subject(:method) do
      described_class.find_payee_id_by_account_id(account_id)
    end

    let(:account_id) { 'ebec22d4-1905-11e8-8a4c-7b32b5a7e49f' }

    it 'returns the correct account id' do
      expect(method).to eq('57244b6e-c35e-11e8-8178-8f80c501f13b')
    end
  end
end
