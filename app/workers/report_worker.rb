class ReportWorker < BaseWorker
  if Rails.env.development?
    require "letter_opener"
    ActionMailer::Base.add_delivery_method :letter_opener, LetterOpener::DeliveryMethod, :location => File.expand_path('../tmp/letter_opener', __FILE__)
    ActionMailer::Base.delivery_method = :letter_opener
  end

  CAPTURE_JS_PATH = Rails.root.join('app', 'services', 'draw', 'capture.js').to_s
  IMAGES_FOLDER_PATH = Rails.root.join('public','report_images').to_s

  def perform
    return if not Rails.env.development? and not DateTime.now.sunday?

    donut_charts = [
        'new_and_repeat_customers_number', 'order_statuses',
        'percentage_of_inventory_sold', 'percentage_of_stock_sold'
    ]

    all_charts = ['total_gross_revenues', 'total_gross_delivery', 'shipping_cost_as_a_percentage_of_total_revenue',
        'average_order_value', 'average_order_size', 'order_statuses', 'orders_number',
        'customers_number', 'new_customers_number', 'repeat_customers_number', 'average_revenue_per_customer',
        'sales_per_visitor', 'average_customer_lifetime_value', 'unique_users_number', 'visits',
        'new_and_repeat_customers_number', 'products_in_stock_number', 'items_in_stock_number', 'products_number'
    ]

    end_date = DateTime.now + 2.days
    start_date = end_date - 6.days


    logger.info "CaptureJS path : #{CAPTURE_JS_PATH}"
    logger.info "Images folder : #{IMAGES_FOLDER_PATH}"

    # 1. Iterate all not expired projects
    # 2. Iterate and capture donut charts for last week
    # 3. Iterate and capture block/big charts for last week
    # 4. Save all to @result and call ReportMailer

    Project.not_expired.each do |project|
      @result = {}

      # Image file name prefix
      prefix = SecureRandom.hex.to_s[0..10]

      logger.info "Starting Generating weekly report for #{project.name} with prefix #{prefix}"

      # Draw donut charts
      # donut_charts.each do |chart|
      #   logger.info "#{chart} file : #{prefix}_donut_#{chart}.png"
      #   @result[chart] = "#{prefix}_donut_#{chart}.png"
      #   capture(project, start_date, end_date, prefix, chart, 'donut')
      # end

      # Draw block all charts
      # all_charts.each do |chart|
      #   logger.info "#{chart} file : #{prefix}_block_#{chart}.png"
      #   @result[chart] = "#{prefix}_block_#{chart}.png"
      #   capture(project, start_date, end_date, prefix, chart, 'block')
      #   @result[chart] = "http://#{Rails.configuration.action_mailer.default_url_options[:host]}:#{Rails.configuration.action_mailer.default_url_options[:port]}/#{@result[chart]}"
      # end

      # Draw big all charts
      all_charts.each do |chart|
        logger.info "#{chart} file : #{prefix}_big_#{chart}.png"

        @result[chart] = "#{prefix}_big_#{chart}.png"
        capture(project, start_date, end_date, prefix, chart, 'big')
        @result[chart] = "http://#{Rails.configuration.action_mailer.default_url_options[:host]}:#{Rails.configuration.action_mailer.default_url_options[:port]}/report_images/#{@result[chart]}"
      end


      logger.info "Generating for #{project.name} done"

      logger.info @result.to_json
      params = {result: @result, project_id: project.id}
      ReportMailer.weekly(params).deliver
    end

  end

  def capture(project, start_date, end_date, prefix, chart, chart_type)
    Phantomjs.run(
        CAPTURE_JS_PATH,
        "--folder=#{IMAGES_FOLDER_PATH}",
        "--project_id=#{project.id}",
        "--from=#{start_date.strftime("%d.%m.%Y")}",
        "--to=#{end_date.strftime("%d.%m.%Y")}",
        "--prefix=#{prefix}",
        "--chart=#{chart}",
        "--chart_type=#{chart_type}"
    )
  end

end
