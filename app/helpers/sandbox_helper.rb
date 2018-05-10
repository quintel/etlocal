module SandboxHelper
  def format_result(result, indent = 0)
    lead  = '  ' * indent

    if result.is_a?(Array)
      lines = result.map { |el| format_result(el, indent + 1) }
      return "#{lead}[\n#{lines.join(",\n")}\n#{lead}]".html_safe
    end

    line =
      if result.is_a?(Numeric)
        number_with_delimiter(result)
      else
        result.inspect
      end

    "#{lead}#{h(line)}".html_safe
  end
end
