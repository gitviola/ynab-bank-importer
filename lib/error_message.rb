# Used to print out friendly error messages that help the user
# understand what went wrong and how to solve it
class ErrorMessage
  require 'colorize'

  def initialize(e)
    @e = e
  end

  def print
    puts summary
    puts heading('Returned error message:')
    puts message
    puts heading('What you can do about the error:')
    puts action
  end

  private

  def summary
    "⚠️  YNAB API Error: #{@e.name} (#{@e.id})".colorize(color: :red,
                                                         background: :default)
  end

  def heading(text)
    [
      "\n\n\n",
      text.colorize(color: :red, background: :default).underline,
      "\n\n"
    ].join
  end

  def message
    pretty_json || @e.message
  end

  def pretty_json
    JSON.pretty_generate(JSON.parse(@e.detail))
  rescue JSON::ParserError => _e
    false
  end

  def action
    if @e.name == 'unauthorized'
      puts '→ Please check your credentials, they seem to be incorrect.'
    elsif @e.id == 404
      puts '→ Double-check that the your configured `budget_id` and' \
           '`ynab_id` for each dumper are correct.'
    else
      puts '→ Please consider reading the error message above to find out more.'
    end
  end
end
