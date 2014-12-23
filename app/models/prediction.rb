class Prediction
  attr_accessor :item, :values

  def initialize(options = {})
    self.item = options[:item]
    self.values = options[:values]
  end
end
