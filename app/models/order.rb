# == Schema Information
#
# Table name: orders
#
#  id                :integer          not null, primary key
#  fields            :text             not null
#  project_id        :integer          not null
#  remote_id         :integer          not null
#  remote_updated_at :datetime         not null
#  created_at        :datetime
#  updated_at        :datetime
#

class Order < ActiveRecord::Base
  serialize :fields, Hash
end
