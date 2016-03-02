# == Schema Information
#
# Table name: products
#
#  id                 :integer          not null, primary key
#  remote_id          :integer          not null
#  project_id         :integer          not null
#  title              :string(255)      default(""), not null
#  created_at         :datetime
#  updated_at         :datetime
#  inventory_quantity :integer          default(0), not null
#  fields             :text
#  remote_updated_at  :datetime
#

class Product < ActiveRecord::Base
  belongs_to :project

  has_many :product_characteristics, dependent: :destroy

  serialize :fields, Hash
end
