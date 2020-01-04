module ::SnitchReporting::SnitchReportHelper
  def file_lines_from_backtrace(backtrace_line)
    backtrace_line[/(\/?\w+\/?)+(\.\w+)+:?\d*/]
  end

  def snippet_for_lines(backtrace_line, line_count: 5)
    file, num = backtrace_line.split(":")
    first_line = num.to_i - 1
    offset_lines = (line_count - 1) / 2
    line_numbers = (first_line - offset_lines)..(first_line + offset_lines)

    lines = File.open(file).read.split("\n")[line_numbers]

    whitespace_count = lines.map { |line| line[/\s*/].length }.min

    lines.map.with_index { |line, idx| [idx + line_numbers.first, line[whitespace_count..-1]] }
  end
end
