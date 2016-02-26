class CharacteristicsFetcherWorker
  include Sidekiq::Worker

  def perform(project_id, date_from, date_to)
    @project_id, @date_from, @date_to = project_id, date_from.to_date, date_to.to_date

    calculate_characteristics
  end

  protected

  def calculate_characteristics
    importer = DataImporters::Importer.new current_project, data

    (@date_from..@date_to).each do |date|
      importer.import! date
    end
  end

  def data
    @data ||= current_project.integration.fetch(@date_from, @date_to)
  end

  def current_project
    @current_project ||= Project.find @project_id
  end
end
