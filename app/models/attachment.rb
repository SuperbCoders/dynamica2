require 'csv'

class Attachment
  attr_reader :item
  attr_reader :filename
  attr_accessor :with_parsing_errors, :total_lines, :processed_lines

  def initialize(item, filename)
    @item = item
    @filename = filename
    @total_lines = 0
    @processed_lines = 0
  end

  def process
    col_sep = detect_col_sep
    SmarterCSV.process filename, chunk_size: 50, headers_in_file: false, user_provided_headers: [:timestamp, :value], col_sep: col_sep do |chunk|
      chunk.each do |row|
        begin
          @total_lines += 1
          timestamp = UTC.parse(row[:timestamp])
          value = parse_float(row[:value])
          item.values.create!(timestamp: timestamp, value: value)
          @processed_lines += 1
        rescue
          self.with_parsing_errors = true
        end
      end
    end
  end

  def not_processed_lines
    total_lines - processed_lines
  end

  private

    def available_col_seps
      [',', ';']
    end

    # Detects col sep depending on the first line of CSV file.
    # It tries to read both timestamp and value with each col sep.
    # The first one that allows it becomes the default col sep.
    def detect_col_sep
      available_col_seps.each do |col_sep|
        begin
          SmarterCSV.process filename, chunk_size: 1, headers_in_file: false, user_provided_headers: [:timestamp, :value], col_sep: col_sep do |chunk|
            data = chunk.first
            break if data[:timestamp].to_s.include?(';')
            timestamp = UTC.parse(data[:timestamp])
            value = parse_float(data[:value])
            return col_sep if timestamp.present? && value.present?
            break
          end
        rescue
        end
      end
      nil
    end

    def parse_float(number)
      return number if number.is_a?(Float)
      Float(number.to_s.gsub(' ', '').gsub(',', '.'))
    end
end
