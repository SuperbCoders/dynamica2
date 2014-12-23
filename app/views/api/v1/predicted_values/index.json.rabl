collection @predictions

child :item do
  attributes :sku
end

child :values, object_root: false do
  attributes :from, :to, :timestamp, :value, :predicted
end