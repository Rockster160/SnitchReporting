module ::SnitchReporting::SnitchReportHelper
  def file_lines_from_backtrace(backtrace_line)
    backtrace_line[/(\/?\w+\/?)+(\.\w+)+:?\d*/]
  end

  def snippet_for_lines(backtrace_line, line_count: 5)
    file, num = backtrace_line.split(":")
    first_line_number = num.to_i
    offset_line_numbers = (line_count - 1) / 2
    line_numbers = (first_line_number - offset_line_numbers - 1)..(first_line_number + offset_line_numbers - 1)

    lines = File.open(file).read.split("\n").map.with_index { |line, idx| [line, idx + 1] }[line_numbers]

    whitespace_count = lines.map { |line, _idx| line[/\s*/].length }.min

    lines.map { |line, idx| [idx, line[whitespace_count..-1], idx == first_line_number] }
  end
end
