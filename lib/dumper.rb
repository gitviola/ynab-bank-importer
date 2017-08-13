class Dumper
  def self.get_dumper(name)
    case name
    when :bbva
      Dumper::Bbva
    when :n26
      Dumper::N26
    when :figo
      Dumper::Figo
    else
      raise "Dumper \"#{name}\" not supported."
    end
  end
end
