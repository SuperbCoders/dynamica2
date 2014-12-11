collection @forecasts
attributes :id, :period, :group_method, :depth, :planned_at, :started_at, :finished_at, :workflow_state
child :item do
  attributes :sku, :name
end