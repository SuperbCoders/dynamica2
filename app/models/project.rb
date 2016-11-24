# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  slug        :string(255)
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  user_id     :integer
#  api_used    :boolean          default(FALSE)
#  demo        :boolean          default(FALSE)
#  guest_token :string(255)
#

class Project < ActiveRecord::Base
  include Alertable

  extend FriendlyId
  friendly_id :slug, use: :slugged

  TIME_PERIOD = 1.year

  # @return [User] who created this project
  belongs_to :user

  has_many :permissions, dependent: :destroy
  has_many :pending_permissions, dependent: :destroy
  has_many :users, through: :permissions

  has_many :items, dependent: :destroy
  has_many :forecasts, dependent: :destroy

  has_many :logs, dependent: :destroy

  has_many :project_characteristics, dependent: :destroy
  has_many :project_order_statuses, dependent: :destroy

  has_many :product_characteristics, dependent: :destroy
  has_many :products, dependent: :destroy

  has_one :shopify_integration, dependent: :destroy, class_name: 'ThirdParty::Shopify::Integration'
  has_one :integration, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[-_A-Za-z0-9]+\z/ }

  before_validation :set_default_values

  default_scope { where(deleted: false) }
  scope :actives, -> { where.not(user_id: nil) }
  scope :not_expired, -> { all.select { |p| !p.expired? } }

  Dynamica::CHART_TYPES.each do |chart_type|
    define_method chart_type do |scope, current_data, prev_data|
      {
          diff: diff_sum(chart_type, current_data, prev_data),
          value: current_data.sum(chart_type),
          data: current_data.send(scope).sum(chart_type)
      }
    end
  end

  def get_all_day_in_period(date_from, date_to, period_value)
    query = <<-EOS
          SELECT *
          FROM generate_series('#{date_from.to_s(:db)}'::timestamp,
            '#{date_to.to_s(:db)}'::timestamp,
            '1 #{period_value}'
          ) AS series
    EOS
    ActiveRecord::Base.connection.execute(query).to_a
  end

  def _get_period_and_step(period)
    period_value = 'day'
    step = 1.day
    if period == 'week'
      step = 1.week
      period_value = 'week'
    end
    if period == 'month'
      step = 1.month
      period_value = 'month'
    end

    return period_value, step
  end


  def full_donut_chart_data(chart, date_from, date_to, period)
    result = {
        items: {},
        data: []
    }

    period_value, step = _get_period_and_step(period)

    case chart
      when 'order_statuses'
        series = get_all_day_in_period(date_from, date_to, period_value)

        order1 = project_order_statuses
            .select("status, sum(count) as count, date_trunc('#{period_value}', date) as date")
            .where('date between ? and ? ', date_from, date_to)
            .group("status, date_trunc('#{period_value}', date)")
        is_empty = false
        if order1.to_a.size == 0
          is_empty = true

          result[:items][:zero] ||= "#ffffff"
          result[:items][:other] ||= rand_color
          (date_from.to_i..date_to.to_i).step(step) do |date|
            temp1 = {}
            temp1[:key] = :zero
            temp1[:date] = Time.at(date).strftime("%m/%d/%y")
            temp1[:value] = 0.99
            result[:data] << temp1

            temp = {}
            temp[:key] = :other
            temp[:date] = Time.at(date).strftime("%m/%d/%y")
            temp[:value] = 0.01
            result[:data] << temp
          end
        end

        order1.each do |order_status|
          # Назначим цвет статусу
          result[:items][order_status.status] ||= rand_color

          temp = {}
          temp[:key] = order_status.status
          temp[:date] = order_status.date.strftime("%m/%d/%y")
          temp[:value] = order_status.count
          temp[order_status.status] = order_status.count
          result[:data] << temp
        end

        if !is_empty
          result[:data].each do |order_status|
            # Пройдемся по результату и найдем данные за дату
            result[:data].map {|r_data|
              if r_data[:date] == order_status[:date]
                data_field = r_data
                order_status[data_field[:key]] = data_field[:value]
              end
            }
          end
        end


        if !is_empty
          series.each do |serie|
            search = false
            order1.each do |order_status|
              if Date.parse(serie["series"]).strftime("%m/%d/%y") == order_status.date.strftime("%m/%d/%y")
                search = true
                break
              end
            end
            if !search
              result[:items].each do |item|
                temp = {}
                temp[:key] = item[0]
                temp[:date] = Date.parse(serie["series"]).strftime("%m/%d/%y")
                temp[:value] = 0
                temp[item[0]] = 0
                result[:data] << temp
              end
            end
          end
        end

        d = []
        result[:data].map.with_index { |r_data, index|

          # Добавим 0 статусы если их нет в хеше
          result[:items].keys.map { |r_key|
            # r_data[r_key] = 0 if not r_data[r_key]
            if r_data[r_key].nil?
              # r_data[r_key] = 0
              #   raise '12'
              temp = {}
              temp[:key] = r_key
              temp[:date] = r_data[:date]
              temp[:value] = 0.to_s
              # temp[order_status.status] = order_status.count
              d << temp
            end

          }

          # Отсортируем
          date = r_data[:date]
          result[:data][index] = Hash[r_data.except(:date)]#.sort]
          result[:data][index][:date] = date

          # Сумма количества всех статусов
          # data = result[:data][index]
          # @summ = 0
          # data.except(:date, :key, :value).keys.map { |k| @summ += data[k] }
          #
          # data[:value] = (data[data[:key]] / @summ.to_f).round(2).to_s if data[data[:key]] > 0
        }
        if !is_empty
          result[:data] = result[:data] + d.uniq { |e| [e[:key], e[:date], e[:key]]}
        end

      when 'new_and_repeat_customers_number'
        return ratio(date_from, date_to, period)


      end

    result
  end

  def ratio(date_from, date_to, period)
    result = {
        items: {},
        data: []
    }
    period_value, step = _get_period_and_step(period)
    series = get_all_day_in_period(date_from, date_to, period_value)


    order1 = project_characteristics
      .select("sum(new_customers_number) as new_customers_number, sum(repeat_customers_number) as repeat_customers_number, date_trunc('#{period_value}', date) as date")
      .where('date between ? and ? ', date_from, date_to)
      .group("date_trunc('#{period_value}', date)")
    is_empty= false
    if order1.to_a.size == 0
      is_empty = true

      result[:items][:zero] ||= "#ffffff"
      result[:items][:other] ||= rand_color
      (date_from.to_i..date_to.to_i).step(step) do |date|
        temp1 = {}
        temp1[:key] = :zero
        temp1[:date] = Time.at(date).strftime("%m/%d/%y")
        temp1[:value] = 0.99
        result[:data] << temp1

        temp = {}
        temp[:key] = :other
        temp[:date] = Time.at(date).strftime("%m/%d/%y")
        temp[:value] = 0.01
        result[:data] << temp
      end
    end

    result[:items][:new] ||= rand_color
    result[:items][:repeat] ||= rand_color

    order1.each do |order_status|
      new_customer = {}
      new_customer[:key] = :new
      new_customer[:date] = order_status.date.strftime("%m/%d/%y")
      new_customer[:value] = order_status.new_customers_number
      new_customer[:new] = order_status.new_customers_number
      result[:data] << new_customer

      repeat_customer = {}
      repeat_customer[:key] = :repeat
      repeat_customer[:date] = order_status.date.strftime("%m/%d/%y")
      repeat_customer[:value] = order_status.repeat_customers_number
      repeat_customer[:repeat] = order_status.repeat_customers_number
      result[:data] << repeat_customer
    end

    if !is_empty
      series.each do |serie|
        search = false
        order1.each do |order_status|
          if Date.parse(serie["series"]).strftime("%m/%d/%y") == order_status.date.strftime("%m/%d/%y")
            search = true
            break
          end
        end
        if !search
          result[:items].each do |item|
            temp = {}
            temp[:key] = item[0]
            temp[:date] = Date.parse(serie["series"]).strftime("%m/%d/%y")
            temp[:value] = 0
            temp[item[0]] = 0
            result[:data] << temp
          end
        end
      end
    end

    return result

  end

  # Число позиций в продаже | Number of Products in Stock
  # – линейная диаграмма
  # – число товаров, у которых >=1 единицы в наличии на складе
  def products_in_stock_number(from, to)
    result = { diff: 0, value: 0, data: {}, products: [] }

    # current_products_data = product_characteristics.where('date >= ? AND date <= ?', from, to)
    # prev_products_data = product_characteristics.where('date >= ? AND date <= ?', (from - (to - from)), from)

    # result[:value] = current_products_data.sum(:sold_quantity)
    # result[:diff] = diff_values(current_products_data.count, prev_products_data.count)


    # Get products
    # current_products_data.pluck(:product_id, :sold_quantity).each do |product_info|
    #   result[:products] << {
    #       product: products.find(product_info[0]),
    #       sold_quantity: product_info[1]
    #   }
    # end

    # Get data for table
    # current_products_data.each do |product_char|
    #   date = product_char.date.strftime("%d-%b-%y")
    #
    #   result[:data][date] ||= 0
    #   result[:data][date] = product_char.sold_quantity
    # end

    result
  end

  # Средняя выручка на покупателя | Average Revenue per Customer (ARPC) – линейная диаграмма
  def average_revenue_per_customer(_scope, current, prev)
    result = { diff: 0, value: 0, data: {} }

    current_value = (current.sum(:total_gross_revenues) / current.sum(:customers_number)).round(2)
    prev_value = (prev.sum(:total_gross_revenues) / prev.sum(:customers_number)).round(2)

    result[:value] = current_value
    result[:diff] = diff_values(current_value, prev_value)

    current.each do |pc|
      date = pc.date.strftime("%d-%b-%y")
      result[:data][date] ||= 0
      result[:data][date] = (pc.customers_number == 0) ? 0 : pc.total_gross_revenues / pc.customers_number
    end
    result
  end

  # / Соотношение старых и новых покупателей | Repeat Customer Rate (RCR) – круговая диаграмма
  def new_and_repeat_customers_number(scope, current_data, prev_data)
    @r = {
        diff: 0,
        value: current_data.sum(:new_customers_number),
        data: [
            {
                color: "#91E873",
                name: "New",
                value: current_data.sum(:new_customers_number)
            },
            {
                color: "#889FCC",
                name: "Repeat",
                value: current_data.sum(:repeat_customers_number)
            }
        ]
    }


    # https://basecamp.com/2476170/projects/11656794/todos/251776993
    if @r[:data][0][:value]== 0 and @r[:data][1][:value] == 0
      @r[:data] = []
    end

    @r
  end

  # Общая стоимость доставки | Gross Delivery Cost – линейная диаграмма
  def total_gross_delivery(_scope, current, prev)
    result = { diff: 0, value: 0, data: {} }

    result[:value] = current.sum(:total_gross_delivery)
    result[:diff] = diff_values(current.sum(:total_gross_delivery), prev.sum(:total_gross_delivery))

    current.each do |pc|
      date = pc.date.strftime("%d-%b-%y")
      result[:data][date] ||= 0
      result[:data][date] =  pc.total_gross_delivery
    end
    result
  end

  # Среднее число товаров в заказе | Average Quantity of Items per Order – линейная диаграмма
  def average_order_size(_scope, current, prev)
    result = { diff: 0, value: 0, data: {}}

    current_data_value = current.sum(:orders_number).zero? ? 0 : (current.sum(:products_number).to_f / current.sum(:orders_number).to_f ).round(2)
    prev_data_value = prev.sum(:orders_number).zero? ? 0 : (prev.sum(:products_number) / prev.sum(:orders_number)).round(2)

    result[:value] = current_data_value
    result[:diff] = diff_values(current_data_value, prev_data_value)

    current.each do |pc|
      date = pc.date.strftime("%d-%b-%y")
      result[:data][date] ||= 0
      result[:data][date] =  (pc.orders_number == 0) ? 0 : pc.products_number / pc.orders_number
    end
    result
  end

  # Calculate / Средний чек | Average Order Value (AOV) – линейная диаграмма
  def average_order_value(_scope, current, prev)
    result = { diff: 0, value: 0, data: {} }

    # Current data value
    current_data_value = current.sum(:orders_number) == 0 ? 0 : (current.sum(:total_gross_revenues) / current.sum(:orders_number)).round(2)
    prev_data_value = prev.sum(:orders_number) == 0 ? 0 : (prev.sum(:total_gross_revenues) / prev.sum(:orders_number)).round(2)

    result[:value] = current_data_value

    # Different between current and prev data
    result[:diff] = diff_values(current_data_value, prev_data_value)

    current.each do |pc|
      date = pc.date.strftime("%d-%b-%y")

      result[:data][date] ||= 0
      result[:data][date] = (pc.orders_number == 0) ? 0 : pc.average_order_value / pc.orders_number
    end
    result
  end

  # @return [Hash] of statuses between from and to
  def order_statuses(from ,to)
    result = { data: [] }
    statuses_hash = project_order_statuses.where('date >= ? and date <= ?', from, to).group(:status).sum(:count)
    logger.info "Statuses"
    logger.info statuses_hash
    statuses_hash.keys.map { |k|
      result[:data] << {
          color: rand_color,
          name: k,
          value: statuses_hash[k]
      }
    }
    result
  end

  # @return [Array] of top 5 seller products
  def top_5_products
    @top = {}
    @products = {}
    @ids = []

    # Retrieve grouped by product_id chars with summed gross_revenue
    p_chars = product_characteristics.group(:id, :product_id).sum(:gross_revenue)
    p_chars.keys.each do |pkey|
      @top[pkey[1]] ||= 0
      @top[pkey[1]] += p_chars[pkey]
    end

    # Sort by gross_revenue and reversed
    @top.sort_by(&:last).reverse[0..3].map { |p_info|
      p = products.find_by(id: p_info[0])
      if p
        @products[p.id] ||= { revenue: 0, title: 0, sales: 0 }
        @products[p.id][:revenue] = p_info[1]
        @products[p.id][:title] = p.title
        @products[p.id][:sales] = product_characteristics.where(product: p).sum(:sold_quantity)
      end
    }
    @products
  end

  # Marks project as a project that uses API
  def api_used!
    update_column(:api_used, true) unless api_used?
  end

  def recent_forecast
    forecasts.order(created_at: :asc, finished_at: :asc).last
  end

  def big_charts_data(scope, current_data, prev_data)
    result = [
    {
        name: "Revenue",
        tr_name: "revenue",
        color: "#6AFFCB",
        value: "#{current_data.sum :total_gross_revenues}",
        diff: diff_sum(:total_gross_revenues, current_data, prev_data),
        data: current_data.send(scope).sum(:total_gross_revenues)
    },
    {
        name: "Orders",
        tr_name: "orders",
        color: "#FF1FA7",
        value: "#{current_data.sum :orders_number}",
        diff: diff_sum(:orders_number, current_data, prev_data),
        data: current_data.send(scope).sum(:orders_number)
    },
    {
        name: "Products sell",
        tr_name: "products_sell",
        color: "#FF7045",
        value: "#{current_data.sum :products_number}",
        diff: diff_sum(:products_number, current_data, prev_data),
        data: current_data.send(scope).sum(:products_number),
        top: top_5_products
    },
    {
        name: "Unic users",
        tr_name: "unic_users",
        color: "#3BD7FF",
        value: "#{current_data.sum :unique_users_number}",
        diff: diff_sum(:unique_users_number, current_data, prev_data),
        data: current_data.send(scope).sum(:unique_users_number)
    },
    {
        name: "Customers",
        tr_name: "customers",
        color: "#FFD865",
        value: "#{current_data.sum :customers_number}",
        diff: diff_sum(:customers_number, current_data, prev_data),
        data: current_data.send(scope).sum(:customers_number)
    }
    ]

    result.each {|gr| gr[:data] = gr[:data].map {|k, v| {'date' => k, 'close' => v}}}

    result
  end

  def shopify_session
    nil if not shopify?
    ShopifyAPI::Session.setup({:api_key => ENV['shopify_api_key'], :secret => ENV['shopify_secret']})
    session = ShopifyAPI::Session.new(self.shop_url, self.integration.access_token)
    ShopifyAPI::Base.activate_session(session)
    session
  end

  # @return [Boolean] whether this project is integrated with Shopify
  def shopify?
    integration.present?
  end

  def shopify_shop_name
    shop_url.split('.myshopify.com')[0]
  end

  def set_project_owner!(user, session = {})
    return if user_id

    if user && update_attributes(user_id: user.id, guest_token: nil)
      user.permissions.create! project: self, all: true
      session[:guest_token] = nil
    else
      update_attribute :guest_token, SecureRandom.hex(32)
      session[:guest_token] = guest_token
    end
  end

  def fetch_data(time_period = Project::TIME_PERIOD)
    CharacteristicsFetcherWorker.perform_async self.id, Time.now - time_period, Time.now
  end

  def parse_google_site_id
    unless google_site_id
      google_site_id = Dynamica::Google.parse_site_id("https://#{shop_url}")
      save
    end
  end

  # @return [DateTime] date of first project data for calendar filter
  # at frontend
  def first_project_data
    if project_characteristics.minimum('date').nil?
      return nil
    end
    (project_characteristics.minimum('date').try(:to_datetime) || created_at.to_datetime)
  end

  # @return [DateTime] date of first product data for calendar filter
  # at frontend
  def first_product_data
    if project_characteristics.minimum('date').nil?
      return nil
    end
    (product_characteristics.minimum('date').try(:to_datetime) || created_at.to_datetime)
  end

  def expired?
    user.subscription.expired?
  end

  def last_update
    ((DateTime.now.to_f - self.updated_at.to_f)/360).to_i
  end

  private

    def rand_color
      "#%06x" % (rand * 0xffffff)
    end

    def diff_values(current_value, previous_value)
      result = (current_value * 100.0 / previous_value - 100)
      result = (result.nan? || result.infinite?) ? 0 : result.round
      return '' if result.zero?
      result > 0 ? "+#{result}%" : "#{result}%"
    end

    def average_sum(relation, field)
      (relation.sum(field) / relation.count).round 1
    end

    def diff_sum(field, current_data, prev_data)
      diff_values current_data.sum(field), prev_data.sum(field)
    end

    def diff_average_sum(field, current_data, prev_data)
      diff_values(average_sum(current_data, field), average_sum(prev_data, field))
    end

    def self.generate_unique_slug
      loop do
        slug = SecureRandom.hex(16)
        break slug unless self.exists?(slug: slug)
      end
    end

    def self.generate_unique_slug_by_name(name)
      derived_slug = name.to_s.parameterize
      if derived_slug.present? &&
        !friendly_id_config.reserved_words.include?(derived_slug) &&
        !Project.exists?(slug: derived_slug)
        derived_slug
      else
        "#{derived_slug}-#{Project.generate_unique_slug[0..4]}"
      end
    end

    def set_default_values
      if slug.blank?
        self.slug = Project.generate_unique_slug_by_name(name)
      end
    end
end
