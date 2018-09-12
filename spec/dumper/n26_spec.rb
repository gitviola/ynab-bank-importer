vcr_options = { cassette_name: 'dumper/n26',
                record: :none,
                match_requests_on: %i[method host path] }

RSpec.describe Dumper::N26, vcr: vcr_options do
  subject(:object) { Dumper::N26.new(params) }

  let(:params) do
    {
      'ynab_id' => '123466',
      'username' => 'username',
      'password' => 'password',
      'iban' => 'DE89370400440532013000'
    }
  end

  let(:transaction_pending) do
    JSON.parse(
      File.read('spec/fixtures/dumper/n26/transaction_pending.json')
    ).first
  end

  let(:transaction_processed) do
    JSON.parse(
      File.read('spec/fixtures/dumper/n26/transaction_processed.json')
    ).first
  end

  let(:transactions) do
    client = TwentySix::Core.authenticate('username', 'password')
    client.transactions
  end

  describe '#fetch_transactions' do
    subject(:method) { object.fetch_transactions }

    it 'sets the transactions' do
      expect(method).to be_truthy
    end

    it 'has the correct transaction amount' do
      expect(method.size).to eq(4)
    end
  end

  # describe '#category_name' do
  #   let(:method) { object.send(:category_name, transactions[2]) }

  #   before do
  #     categories = ['micro-v2-food-groceries' => 'Food']
  #     allow(object).to receive(:@categories).and_return(categories)
  #   end

  #   context 'when set_category is set to true' do
  #     let(:params) do
  #       {
  #         'ynab_id' => '123466',
  #         'username' => 'username',
  #         'password' => 'password',
  #         'iban' => 'DE89370400440532013000',
  #         'set_category' => true
  #       }
  #     end

  #     it 'returns the N26 category name' do
  #       expect(method).to eq('Food & Groceries')
  #     end
  #   end

  #   context 'when set_category is set to false' do
  #     it 'returns nil' do
  #       expect(method).to eq(nil)
  #     end
  #   end
  # end

  describe '#memo' do
    let(:method) { object.send(:memo, transaction) }

    context 'when reference text and city are present' do
      let(:transaction) { transactions.last }

      it 'merges reference text and city name' do
        expect(method).to eq('Bargeldabhebung BARCELONA')
      end
    end

    context 'when only city name is present' do
      let(:transaction) { transactions[2] }

      it 'returns the city name' do
        expect(method).to eq('BARCELONA')
      end
    end

    context 'when only reference text is present' do
      let(:transaction) { transactions[1] }

      it 'returns the reference text' do
        expect(method).to eq('Test fuer eine Api')
      end
    end
  end

  describe '#amount' do
    let(:method) { object.send(:amount, transaction) }

    context 'when amount is below 1 euro' do
      let(:transaction) { transactions.first }

      it 'converts it correctly to an integer' do
        expect(method).to eq(-10)
      end
    end

    context 'when amount is below 10 euros' do
      let(:transaction) { transactions[2] }

      it 'converts it correctly to an integer' do
        expect(method).to eq(5440)
      end
    end

    context 'when amount is greater than 100 euros' do
      let(:transaction) { transactions[3] }

      it 'converts it correctly to an integer' do
        expect(method).to eq(-500_000)
      end
    end
  end

  describe '#withdrawal?' do
    let(:method) { object.send(:withdrawal?, transaction) }

    context 'when transaction is withdrawal' do
      let(:transaction) { transactions.last }

      it 'returns true' do
        expect(method).to be_truthy
      end
    end

    context 'when transaction is not a withdrawal' do
      let(:transaction) { transactions.first }

      it 'returns true' do
        expect(method).to be_falsy
      end
    end
  end

  describe '#import_id' do
    let(:method) { object.send(:import_id, transactions.first) }

    it 'sets it correctly' do
      expect(method).to eq('46c9ccde424652bc013dca9b408dcdec')
    end

    it 'is the same for a pending transaction and a processed transaction' do
      expect(
        object.send(:import_id, transaction_pending)
      ).to eq(object.send(:import_id, transaction_processed))
    end
  end

  describe '#calculated_timestamp' do
    it 'is the same for a pending transaction and a processed transaction' do
      expect(
        object.send(:calculated_timestamp, transaction_pending)
      ).to eq(object.send(:calculated_timestamp, transaction_processed))
    end
  end
end
