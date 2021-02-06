class Dumper
  # Implements logic to fetch transactions via the Fints protocol
  # and implements methods that convert the response to meaningful data.
  class DeutscheBank < Fints
    def payee_name(transaction)
      if transaction.sepa["SVWZ"].nil?
        puts transaction.inspect
        puts transaction.to_json
      end
      if super == "DEUTSCHE BANK" || super == "" # This is either a interest statement or more likely a Payment with Apple Pay
        if transaction.sepa.empty?
          puts transaction.transaction_code
          transaction.transaction_code
        else
          transaction.sepa["SVWZ"].split('//')[0]
        end
      else
        super
      end
    end
    def memo(transaction)
      if transaction.sepa.empty?
        transaction.information
      else
        transaction.sepa["SVWZ"]
      end
    end
  end
end
