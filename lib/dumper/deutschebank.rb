class Dumper
  # Implements logic to fetch transactions via the Fints protocol
  # and implements methods that convert the response to meaningful data.
  class DeutscheBank < Fints
    def payee_name(transaction)
      # puts "transaction"
      #   puts transaction.inspect
      #   puts "transaction.json"
      #   puts transaction.to_json
      #   puts "split"
      #   puts transaction.sepa["SVWZ"].split('//')[0]
      if super == "DEUTSCHE BANK" # This is either a interest statement or more likely a Payment with Apple Pay
        puts transaction.sepa["SVWZ"].split('//')[0]
        transaction.sepa["SVWZ"].split('//')[0]
      else
        puts super
        super
      end
    end
    def memo(transaction)
      transaction.sepa["SVWZ"]
    end
  end
end
