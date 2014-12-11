object @forecast
attributes :id, :period, :depth, :group_method, :workflow_state, :planned_at
child :item do
  attributes :sku, :name
end