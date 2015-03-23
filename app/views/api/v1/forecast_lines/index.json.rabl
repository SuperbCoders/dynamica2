collection @forecast_lines

child(:item, unless: -> (forecast_line) { forecast_line.summary? }) do
  attributes :sku
end

node(:summary, if: -> (forecast_line) { forecast_line.summary? }) do
  true
end

child :predicted_values, object_root: false do
  attributes :from, :to, :value, :predicted
end