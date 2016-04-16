require 'rails_helper'

RSpec.describe ChartsDataController, :type => :controller do
  clean_database

  # Generate user, project and grant permissions
  user = FactoryGirl.create(:user)
  @project = project =  FactoryGirl.create(:project, user: user)
  user.permissions.create(project: project, all: true)

  # Generate test data
  total_statistic, statistic, products_statistic = generate_test_demo_data(project)

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end

  describe 'GET #products_characteristics' do
    before {
      start_date = project.project_characteristics.first.date.strftime("%m.%d.%Y")
      end_date = project.project_characteristics.last.date.strftime("%m.%d.%Y")
      get :products_characteristics, format: :json, chart: 'products_revenue', from: start_date, to: end_date, project_id: project.id
    }

    it 'should calculate products revenue' do
      expect(json_body[0][:gross_revenue]).to eq total_gross_revenue(json_body[0][:product_id], products_statistic)
    end
  end

  describe 'GET #big_chart_data' do
    before {
      start_date = project.project_characteristics.first.date.strftime("%m.%d.%Y")
      end_date = project.project_characteristics.last.date.strftime("%m.%d.%Y")
      get :big_chart_data, format: :json, from: start_date, to: end_date, project_id: project.id
    }

    it 'should calculate total revenue' do
      compare_total_values('revenue', :total_gross_revenues, total_statistic, statistic)
    end

    it 'should calculate total orders' do
      compare_total_values('orders', :orders_number, total_statistic, statistic)
    end

    it 'should calculate total customers' do
      compare_total_values('customers', :customers_number, total_statistic, statistic)
    end

    it 'should calculate total products_sell' do
      compare_total_values('products_sell', :products_number, total_statistic, statistic)
    end
  end

  describe 'GET #other_chart_data' do
    before {
      start_date = project.project_characteristics.first.date.strftime("%m.%d.%Y")
      end_date = project.project_characteristics.last.date.strftime("%m.%d.%Y")
      get :other_chart_data, format: :json, from: start_date, to: end_date, project_id: project.id
    }

    it 'should calculate total_revenu' do
      compare_other_chart_values(:total_revenu, :total_gross_revenues, total_statistic, statistic)
    end

    it 'should calculate products_number' do
      compare_other_chart_values(:products_number, :products_number, total_statistic, statistic)
    end


    it 'should calculate customers_number' do
      compare_other_chart_values(:customers_number, :customers_number, total_statistic, statistic)
    end

    it 'should calculate new_customers_number' do
      compare_other_chart_values(:new_customers_number, :new_customers_number, total_statistic, statistic)
    end

    # pending 'should calculate average_order_value'
    # pending 'should calculate average_order_size'
    # pending 'should calculate repeat_customers_number'
    # pending 'should calculate average_revenue_per_customer'
    # pending 'should calculate products_in_stock_number'
    # pending 'should calculate sales_per_visitor'
    # pending 'should calculate average_customer_lifetime_value'
    # pending 'should calculate unique_users_number'
    # pending 'should calculate visits'
    # pending 'should calculate items_in_stock_number'
    # pending 'should calculate percentage_of_inventory_sold'
    # pending 'should calculate percentage_of_stock_sold'
    # pending 'should calculate shipping_cost_as_a_percentage_of_total_revenue'
  end

  describe 'GET #full_chart_data' do

  end

  describe 'GET #full_chart_check_points' do

  end

  def start_date
    @project.project_characteristics.first.date.strftime("%m.%d.%Y")
  end

  def end_date
    @project.project_characteristics.last.date.strftime("%m.%d.%Y")
  end

  def compare_other_chart_values(value_type, value_field, total_statistic, statistic)
    # p 'compare_other_chart_values'
    # p value_type
    # p value_field

    data = json_body[value_type]
    # p data
    expect(data[:value].to_f).to eq total_statistic[value_field]
    data[:data].map { |date_values|
      date = date_values[:date].to_datetime.strftime('%D').gsub('/','-')
      expect(statistic[date][value_field]).to eq date_values[:close]
    }
  end

  def compare_total_values(value_type, value_field, total_statistic, statistic)
    data = select_total(value_type, json_body)
    expect(data[:value].to_f).to eq total_statistic[value_field]
    data[:data].map { |date_values|
      date = date_values[:date].to_datetime.strftime('%D').gsub('/','-')
      expect(statistic[date][value_field]).to eq date_values[:close]
    }
  end

  def select_total(name, data)
    data.select { |d| d[:tr_name] == name }[0]
  end

  def total_gross_revenue(product_id, products_statistic)
    total_gross_revenue = 0
    products_statistic.keys.map { |day|
      products_statistic[day].map { |product_char| total_gross_revenue += product_char.gross_revenue if product_char.product_id == product_id }
    }
    total_gross_revenue
  end


end
