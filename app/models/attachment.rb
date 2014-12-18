require 'csv'

class Attachment < ActiveRecord::Base
  attr_accessor :with_parsing_errors

  mount_uploader :file, FileUploader

  belongs_to :project

  validates :project, presence: true
  validates :file, presence: true

  def data
    @data ||= parse
  end

  private

    def parse
      self.with_parsing_errors = false
      result = {}
      CSV.foreach("#{Rails.root}/public/#{file.url}", col_sep: ';', encoding: 'UTF-8') do |row|
        begin
          result[Time.parse(row[0])] = Float(row[1])
        rescue
          puts row.inspect
          self.with_parsing_errors = true
        end
      end
      result
    end
end
