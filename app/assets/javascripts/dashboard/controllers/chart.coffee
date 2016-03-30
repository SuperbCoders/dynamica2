class ChartController
  constructor: (@rootScope, @scope, @Projects, @http) ->
    vm = @
    vm.slug = @rootScope.$stateParams.slug
    vm.chart = @rootScope.$stateParams.chart
    vm.project = @rootScope.$stateParams.project
    vm.range =
      chart: vm.chart
      from: @rootScope.$stateParams.from
      to: @rootScope.$stateParams.to

    vm.datepicker = $('.datePicker')

    if not vm.range.from or not vm.range.to
      @rootScope.$state.go('projects.list')

    @init_dashboard()
    @set_default_range()

    if not @project
      @Projects.search({slug: vm.slug}).$promise.then( (project) ->
        vm.project = project
        vm.fetch()
      )
    else
      @fetch()

  charts_fetch: (chart_type) ->
    vm = @

    chart_url = "/charts_data/#{chart_type}"
    chart_params =
      from: vm.range.from
      to: vm.range.to
      project_id: vm.project.id
      chart: vm.chart

    vm.http.get chart_url, params: chart_params

  fetch: ->
    vm = @
    @charts_fetch('full_chart_data').success((response) ->
      vm.data = response['full']
      vm.check_points = response['check_points']
      vm.init_line_area3_chart($('.areaChartTotal_1'), vm.data)
    )

  fit2Limits: (pckr, date, max) ->
    start = moment(pckr.datepicker('getStartDate'))
    end = moment(pckr.datepicker('getEndDate'))
    if max
      moment.max(start, date).startOf('day')._d
    else
      moment.min(end, date).startOf('day')._d

  set_default_range: ->
    vm = @
    today = moment()
    vm.range.raw_start = rangeStart = moment(today).startOf('month')
    vm.range.raw_end = rangeEnd = moment(today).endOf('month')
    vm.range.from = rangeStart.format('MM.DD.YYYY')
    vm.range.to = rangeEnd.format('MM.DD.YYYY')

    vm.set_datepicker_date(rangeStart, rangeEnd)

  init_line_area3_chart: (el, data) ->
    console.log data

    dates = []
    values = []

    el.find('svg').remove()
    make_y_axis = -> d3.svg.axis().scale(y).orient('left').ticks 5
    make_x_axis = -> d3.svg.axis().scale(x).orient('bottom').ticks 5


    i = 0

    while i < data['data'].length
      obj = data['data'][i]
      dates.push moment(obj.date)
      values.push obj.close
      i++

    margin =
      top: 30
      right: 35
      bottom: 50
      left: 100

    width = el.width() - (margin.left) - (margin.right)
    height = el.height() - (margin.top) - (margin.bottom)
    tooltip = $('#tooltip')
    tooltip_content = $('#tooltip_content')
    bisectDate = d3.bisector((d) -> d.date).left
    parseDate = d3.time.format('%d-%b-%y').parse
    #var currencyFormatter = d3.format(",.0f");

    currencyFormatter = (e) ->
      e.toString().replace /(\d)(?=(\d{3})+(?!\d))/g, '$1 '

    x = d3.time.scale().domain([
      moment.min(dates)
      moment.max(dates)
    ]).range([0,width])
    y = d3.scale.linear().domain([
      0
      1000 * Math.floor(Math.max.apply(null, values) / 1000 + 1)
    ]).range([height,0])
    line = d3.svg.line().x((d) ->
      x d.x
    ).y((d) ->
      y d.y
    )
    area_x = d3.time.scale().range([0,width])
    area_y = d3.scale.linear().range([height,0])
    area = d3.svg.area().x((d) ->
      area_x d.date
    ).y0(height).y1((d) ->
      area_y d.close
    ).interpolate('monotone')
    valueline = d3.svg.line().x((d) ->
      x d.date
    ).y((d) ->
      y d.close
    ).interpolate('monotone')
    xAxis = d3.svg.axis().scale(x).ticks(data.length - 1).tickFormat(d3.time.format('%b %d')).orient('bottom')
    yAxis = d3.svg.axis().scale(y).ticks(5).tickFormat((d) ->
      if d == 0 then '' else currencyFormatter(d) + '$'
    ).orient('left')
    svg = d3.select(el[0]).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
    svg.append('g').attr('class', 'x axis').style('font-size', '14px').style('fill', '#A5ADB3').attr('transform', 'translate(0,' + height + ')').call xAxis
    svg.append('g').attr('class', 'y axis').attr('transform', 'translate(' + -25 + ', 0)').style('font-size', '14px').style('fill', '#A5ADB3').attr('class', 'grid').call yAxis
    svg.append('g').attr('class', 'gray_grid').call make_y_axis().tickSize(-width, 0, 0).tickFormat('')

    for d in data['data']
      d.date = parseDate(d.date)
      d.close = +d.close
      return

    # Scale the range of the data
    x.domain d3.extent(data['data'], (d) -> d.date )
    y.domain [
      0
      d3.max(data['data'], (d) ->
        Math.max d.close
      )
    ]
    area_x.domain d3.extent(data['data'], (d) -> d.date )
    area_y.domain [
      0
      d3.max(data['data'], (d) ->
        d.close
      )
    ]
    svg.append('path').attr('class', 'line').attr 'd', valueline(data['data'])
    # Add the scatterplot
    svg.append('line').attr('id', 'line_for_dot').attr('class', 'line_for_dot').style('stroke', '#D0E3EE').style('stroke-width', '2').attr('x1', 0).attr('x2', 0).attr('y1', height).attr 'y2', 0
    line_for_dot = d3.select('#line_for_dot')
    svg.selectAll('dot').data(data['data']).enter().append('circle').attr('r', 0).attr('data-y-value', (d, i) ->
      y d.close
    ).attr('class', (d, i) ->
      'mark_v3 '
      #return 'mark_v3 ' + (i == 0 || (i == data.length - 1) ? ' hidden' : '');
    ).attr('id', (d, i) ->
      'dot_' + i
    ).attr('cx', (d) ->
      x d.date
    ).attr 'cy', (d) ->
      `var i`
      y d.close
    svg.append('circle').attr('r', 7).attr('id', 'big_dot').attr('class', 'big_dot mark_v2').attr('cx', 0).attr 'cy', 0
    tracing_anim_duration = 150
    distance = x(data['data'][0].date) - x(data['data'][1].date)
    big_dot = d3.select('#big_dot')
    i = 0
    while i < data['data'].length
      svg.append('rect').attr('class', 'graph-tracing-catcher tracingCatcher').attr('data-dot', '#dot_' + data.length - i - 1).style('opacity', 0).attr('x', ->
        width - x(data[i].date)
      ).attr('y', 0).attr('width', width).attr('height', height).style('transform', 'translate(' + distance / -2 + 'px)').on('mouseenter', (e) ->
        $this = $(this)
        dot_id = d3.select(this).attr('data-dot')
        cur_id = dot_id.replace(/\D/g, '') * 1
        cur_dot = $('#dot_' + cur_id)
        x0 = area_x.invert(cur_dot.attr('cx'))
        y0 = area_y.invert(cur_dot.attr('cy')).toFixed(0)
        if prevTracingDot != undefined
          big_dot.transition().duration(tracing_anim_duration).attr('cx', $this.attr('x')).attr 'cy', cur_dot.attr('data-y-value')
          line_for_dot.transition().duration(tracing_anim_duration).attr('x1', $this.attr('x')).attr('x2', $this.attr('x')).attr 'y2', cur_dot.attr('data-y-value')
          tooltip_content.empty().css('top', cur_dot.attr('data-y-value') * 1 + margin.top - 15 + 'px').append($('<div class="tooltip-title" />').text(moment(x0).format('dddd, D MMMM YYYY'))).append $('<div class="tooltip-value" />').text(currencyFormatter(y0) + '$')
          tooltip.css 'left', $this.attr('x') * 1 + margin.left + 'px'
          splashTracing cur_id, if cur_id > prevTracingDot then 'left' else 'right'
        return
      ).on 'mouseleave', (e) ->
        dot_id = d3.select(this).attr('data-dot')
        prevTracingDot = dot_id.replace(/\D/g, '') * 1
        return
      i++
    return

  set_date_range: (range_type) ->
    vm = @
    return if range_type not in ["0","1","2","3","4","5"]
    return if not vm.datepicker

    period = parseInt(range_type)
    today = moment()

    if period == 0
      #  Current month
      rangeStart = moment(today).startOf('month')
      rangeEnd = moment(today).endOf('month')
    else if period == 1
      #  Previous month
      rangeStart = moment(today).subtract(1, 'month').startOf('month')
      rangeEnd = moment(today).subtract(1, 'month').endOf('month')
    else if period == 2
      #  Last 3 month
      rangeStart = moment(today).subtract(3, 'month')
      rangeEnd = moment(today)
    else if period == 3
      #  Last 6 month
      rangeStart = moment(today).subtract(6, 'month')
      rangeEnd = moment(today)
    else if period == 4
      #  Last year
      rangeStart = moment(today).subtract(12, 'month')
      rangeEnd = moment(today)
    else if period == 5
      #  All time
      rangeStart = moment(vm.datepicker.datepicker('getStartDate'))
      rangeEnd = moment(vm.datepicker.datepicker('getEndDate'))

    vm.range.raw_start = rangeStart
    vm.range.raw_end = rangeEnd
    vm.range.from = rangeStart.format('MM.DD.YYYY')
    vm.range.to = rangeEnd.format('MM.DD.YYYY')

    vm.set_datepicker_date(rangeStart, rangeEnd)
    vm.fetch()
    return

  translate_chart_name: (name) ->
    names_ru =
      overview: 'Обзор'
      general: 'Базовые'
      customers: 'Покупатели'
      inventory: 'Товары'
      shipping_cost_as_a_percentage_of_total_revenue: 'Доля доставки от общей стоимости'
      average_order_value: 'Средния стоимость заказа'
      average_order_size: 'Средняя размер заказа'
      customers_number: 'Число покупателей'
      new_customers_number: 'Число новых покупателей'
      repeat_customers_number: 'Чилсо повторных покупателей'
      ratio_of_new_customers_to_repeat_customers: 'Отшение новых покупателей к повторным'
      average_revenue_per_customer: 'Средняя сумма на покупателя'
      sales_per_visitor: 'Покупок на посетителей'
      average_customer_lifetime_value: 'Среднее время проведенное клиентом'
      unique_users_number: 'Количество уникальных посетителей'
      visits: 'Число визитов'
      products_in_stock_number: 'Продуктов в продаже'
      items_in_stock_number: 'Позиций на складе'
      percentage_of_inventory_sold: 'Процент проданных товаров'
      percentage_of_stock_sold: 'Процент запаса на складе'
      products_number: 'Количество товаров'
      total_gross_revenues: 'Общая выручка'
    names_en =
      overview: 'Overview'
      general: 'General'
      customers: 'Customers'
      inventory: 'Inventory'
      total_revenu: 'Gross Revenue'
      shipping_cost_as_a_percentage_of_total_revenue: 'Shipping Cost As A Percentage Of Total Revenue'
      average_order_value: 'Average Order Value'
      average_order_size: 'Average Order Size'
      customers_number: 'Customers Number'
      new_customers_number: 'New Customers Number'
      repeat_customers_number: 'Repeat Customers Number'
      ratio_of_new_customers_to_repeat_customers: 'Ratio Of New Customers To Repeat Customers'
      average_revenue_per_customer: 'Average Revenue Per Customer'
      sales_per_visitor: 'Sales Per Visitor'
      average_customer_lifetime_value: 'Average Customer Lifetime Value'
      unique_users_number: 'Unique Users Number'
      visits: 'Visits'
      products_in_stock_number: 'Products_in_stock_number'
      items_in_stock_number: 'Items In Stock Number'
      percentage_of_inventory_sold: 'Percentage Of Inventory Sold'
      percentage_of_stock_sold: 'Rercentage Of Stock Sold'
      products_number: 'Products Number'
      total_gross_revenues: 'Gross Revenue'
    if @rootScope.locale is 'ru' then names_ru[name] else names_en[name]

  set_datepicker_date: (rangeStart, rangeEnd) ->
    vm = @
    vm.datepicker.datepicker('setDates', [
      vm.fit2Limits(vm.datepicker, rangeStart, true)
      vm.fit2Limits(vm.datepicker, rangeEnd)
    ]).datepicker 'update'

  init_dashboard: ->
    vm = @
    $('.selectpicker').selectpicker({size: 70, showTick: false, showIcon: false})
    $('.page').addClass('dashboard_page')

    vm.datepicker.datepicker(
      multidate: 2
      startDate: '-477d'
      endDate: '0'
      toggleActive: true
      orientation: 'bottom left'
      format: 'M dd, yyyy'
      container: $('.datePicker').parent()
      multidateSeparator: ' – ')

  parse_diff: (diff_str) -> parseInt(diff_str)
  chart_changed: (chart) -> @rootScope.$state.go('projects.chart', {project: @project,slug: @project.slug,chart: @range[chart],from: @range.from,to: @range.to})
  toggle_debug: -> if @debug is true then @debug = false else @debug = true
@application.controller 'ChartController', ['$rootScope', '$scope', 'Projects', '$http', ChartController]
