require 'zip'

class PredictedValuesController < ApplicationController
  before_action :set_project
  before_action :set_forecast

  # GET /forecasts/:forecast_id/predicted_values
  def index
    authorize! :read, @project
    if @forecast.forecast_lines.size <= 0
      render csv: []
    elsif @forecast.forecast_lines.size == 1
      render_single_csv
    else
      render_multiple_csv
    end 
  end

  private

    def set_project
      @project = Project.find_by!(slug: params[:project_id])
    end

    def set_forecast
      @forecast = @project.forecasts.find(params[:forecast_id])
    end

    def render_single_csv
      @forecast_line = @forecast.forecast_lines.first
      render csv: @forecast_line.predicted_values.order(from: :asc), only: [:from, :to, :value, :predicted]
      response.headers['Content-Disposition'] = 'attachment; filename="' + @forecast_line.item.display_name + '.csv"'
    end

    def render_multiple_csv
      filename = "dynamica-#{@project.slug}-#{Time.now}.zip"
      t = Tempfile.new(filename) # Create tempfile

      # Write zip content into tempfile
      Zip::OutputStream.open(t.path) do |z|
        @forecast.forecast_lines.each do |forecast_line|
          csv_name = forecast_line.item.try(:display_name) || 'summary'
          z.put_next_entry("#{csv_name}.csv")
          data = ""
          data << PredictedValue.csv_header.to_s
          forecast_line.predicted_values.order(from: :asc).each do |predicted_value|
            data << predicted_value.to_csv_row.to_s
          end
          z.write data
        end
      end

      # Render this file
      send_file t.path, type: 'application/zip',
                        disposition: 'attachment',
                        filename: filename
      t.close
    end

end
