# This class generates demo projects to the users
# It uses demo@dynamica.cc user's projects as a source
class Demo
  attr_reader :user

  def initialize(user_id)
    @user = User.find(user_id)
  end

  def self.create(user_id)
    new(user_id).create
  end

  def create
    projects.each do |project|
      create_project(project)
    end
  end

  private

    def demo_user
      @demo_user = User.find_by(email: 'demo@dynamica.cc')
    end

    def projects
      @projects = demo_user.own_projects
    end

    def create_project(source)
      project = user.own_projects.create!(name: source.name, demo: true)
      user.permissions.create!(project: project, all: true)
      create_items(project, source)
      create_forecasts(project, source)
    end

    def create_items(project, source)
      source.items.each do |source_item|
        item = project.items.create!(sku: source_item.sku, name: source_item.name)
        source_item.values.each do |source_value|
          item.values.create!(timestamp: source_value.timestamp, value: source_value.value)
        end
      end
    end

    def create_forecasts(project, source)
      source.forecasts.each do |source_forecast|
        forecast = project.forecasts.create!(period: source_forecast.period, depth: source_forecast.depth, group_method: source_forecast.group_method)
        forecast.start!
      end
    end
end
