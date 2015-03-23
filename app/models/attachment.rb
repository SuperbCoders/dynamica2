require 'csv'

class Attachment
  attr_reader :file
  attr_accessor :with_parsing_errors

  def initialize(file)
    @file = file
  end

  def data
    @data ||= parse
  end

  private

    def parse
      self.with_parsing_errors = false
      result = {}
      CSV.foreach("#{Rails.root}/public/#{file.url}", col_sep: ';', encoding: 'UTF-8') do |row|
        begin
          result[UTC.parse(row[0])] = Float(row[1])
        rescue
          self.with_parsing_errors = true
        end
      end
      result
    end
end
