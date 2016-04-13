class ChartController
  constructor: (@rootScope, @scope, @Projects, @http, @T) ->
    console.log 'ChartController constructor'
    vm = @
    vm.slug = @rootScope.$stateParams.slug
    vm.chart = @rootScope.$stateParams.chart
    vm.project = @rootScope.$stateParams.project
    vm.date_range = 0
    vm.range =
      chart: vm.chart
      from: @rootScope.$stateParams.from
      to: @rootScope.$stateParams.to

    vm.datepicker = $('.datePicker')

    if not vm.range.from or not vm.range.to
      @rootScope.$state.go('projects.list')

    @scope.$watch('vm.date_range', (old_val) -> vm.set_date_range(old_val) )

    @init_dashboard()

    # Set datepicker dates
    console.log vm.range
    vm.range.raw_start = rangeStart = moment(vm.range.from, 'MM.DD.YYYY')
    vm.range.raw_end = rangeEnd = moment(vm.range.to, 'MM.DD.YYYY')
    vm.range.from = rangeStart.format('MM.DD.YYYY')
    vm.range.to = rangeEnd.format('MM.DD.YYYY')

    @Projects.search({slug: vm.slug}).$promise.then( (project) ->
      vm.project = project
      vm.rootScope.currency = vm.project.currency
      vm.rootScope.set_datepicker_start_date(vm.datepicker, vm.project.first_project_data)
      vm.rootScope.set_datepicker_date(vm.datepicker, vm.range.raw_start, vm.range.raw_end)
      vm.fetch()
    )

  fetch: ->
    vm = @

    return if not vm.project

    chart_url = "/charts_data/full_chart_data"
    chart_params =
      from: vm.range.from
      to: vm.range.to
      project_id: vm.project.id
      chart: vm.chart

    vm.http.get(chart_url, params: chart_params).success((response) ->
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

  init_line_area3_chart: (el, data) ->
    return if data['data'].length < 1
    vm = @
    dates = []
    values = []
    i = 0

    make_y_axis = -> d3.svg.axis().scale(y).orient('left').ticks 5
    make_x_axis = -> d3.svg.axis().scale(x).orient('bottom').ticks 5

    el.find('svg').remove()

    while i < data['data'].length
      obj = data['data'][i]
      dates.push moment(obj.date)
      values.push obj.close
      i++

    margin =
      top: 30
      right: 35
      bottom: 50
      left: 80
    width = el.width() - (margin.left) - (margin.right)
    height = el.height() - (margin.top) - (margin.bottom)
    tooltip = $('#tooltip')
    tooltip_content = $('#tooltip_content')
    bisectDate = d3.bisector((d) ->
      #console.log(d);
      d.date
    ).left
    parseDate = d3.time.format('%d-%b-%y').parse
    #var currencyFormatter = d3.format(",.0f");

    currencyFormatter = (e) ->
      e.toString().replace /(\d)(?=(\d{3})+(?!\d))/g, '$1 '

    x = d3.time.scale().domain([
      moment.min(dates)
      moment.max(dates)
    ]).range([
      0
      width
    ])
    y = d3.scale.linear().domain([
      0
      1000 * Math.floor(Math.max.apply(null, values) / 1000 + 1)
    ]).range([
      height
      0
    ])
    line = d3.svg.line().x((d) ->
      x d.x
    ).y((d) ->
      y d.y
    )
    area_x = d3.time.scale().range([
      0
      width
    ])
    area_y = d3.scale.linear().range([
      height
      0
    ])
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

    RANGE_TICKS = 6 if dates.length > 10
    RANGE_TICKS = 12 if dates.length > 100
    RANGE_TICKS = 18 if dates.length > 1000
    xAxis = d3.svg.axis().scale(x).ticks(RANGE_TICKS).tickFormat(d3.time.format('%b %d')).orient('bottom')
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

#    data.forEach (d) ->
#      d.date = parseDate(d.date)
#      d.close = +d.close
#      return
    # Scale the range of the data

    x.domain d3.extent(data['data'], (d) ->
      d.date
    )
    y.domain [
      0
      d3.max(data['data'], (d) ->
        Math.max d.close
      )
    ]
    area_x.domain d3.extent(data['data'], (d) ->
      d.date
    )
    area_y.domain [
      0
      d3.max(data['data'], (d) ->
        d.close
      )
    ]
    gradient = svg.append('svg:defs').append('svg:linearGradient').attr('id', 'area_gradient_1').attr('x1', '0%').attr('y1', '0%').attr('x2', '0%').attr('y2', '100%').attr('spreadMethod', 'pad')
    gradient.append('svg:stop').attr('offset', '0%').attr('stop-color', '#dfe7ff').attr 'stop-opacity', 1
    gradient.append('svg:stop').attr('offset', '100%').attr('stop-color', '#f6f6f6').attr 'stop-opacity', 0
    svg.append('path').attr('class', 'line').attr 'd', valueline(data['data'])
    svg.append('path').datum(data['data']).attr('class', 'area area_v1').attr('d', area).style 'fill', 'url(#area_gradient_1)'
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
      svg.append('rect').attr('class', 'graph-tracing-catcher tracingCatcher').attr('data-dot', '#dot_' + data['data'].length - i - 1).style('opacity', 0).attr('x', ->
        width - x(data['data'][i].date)
      ).attr('y', 0).attr('width', width).attr('height', height).style('transform', 'translate(' + distance / -2 + 'px)').on('mouseenter', (e) ->
        $this = $(this)
        dot_id = d3.select(this).attr('data-dot')
        cur_id = dot_id.replace(/\D/g, '') * 1
        cur_dot = $('#dot_' + cur_id)
        x0 = area_x.invert(cur_dot.attr('cx'))
        y0 = area_y.invert(cur_dot.attr('cy')).toFixed(0)
        prevTracingDot = dot_id.replace(/\D/g, '') * 1
        if prevTracingDot != undefined
          big_dot.transition().duration(tracing_anim_duration).attr('cx', $this.attr('x')).attr 'cy', cur_dot.attr('data-y-value')
          line_for_dot.transition().duration(tracing_anim_duration).attr('x1', $this.attr('x')).attr('x2', $this.attr('x')).attr 'y2', cur_dot.attr('data-y-value')
          tooltip_content.empty().css('top', cur_dot.attr('data-y-value') * 1 + margin.top - 15 + 'px').append($('<div class="tooltip-title" />').text(moment(x0).format('dddd, D MMMM YYYY'))).append $('<div class="tooltip-value" />').text(currencyFormatter(y0) + '$')
          tooltip.css 'left', $this.attr('x') * 1 + margin.left + 'px'
          vm.splashTracing cur_id, if cur_id > prevTracingDot then 'left' else 'right'
        return
      ).on 'mouseleave', (e) ->
        dot_id = d3.select(this).attr('data-dot')
        prevTracingDot = dot_id.replace(/\D/g, '') * 1
        return
      i++
    return

  datepicker_changed: ->
    vm = @
    dates = vm.datepicker_date.split(' – ')
    if dates.length == 2
      vm.range.raw_start = moment(dates[0])
      vm.range.raw_end = moment(dates[1])
      vm.range.from = vm.range.raw_start.format('MM.DD.YYYY')
      vm.range.to = vm.range.raw_end.format('MM.DD.YYYY')
      vm.fetch()

  set_date_range: (range_type) ->
    vm = @
    return if range_type not in ["0","1","2","3","4","5","6"]
    return if not vm.datepicker

    vm.rootScope.set_date_range(vm.range, parseInt(range_type))
    vm.rootScope.set_datepicker_date(vm.datepicker, vm.range.raw_start, vm.range.raw_end)
    vm.fetch()
    return

  splashTracing: (id, direction) ->
    new_r = 5
    #console.log(id, direction);
    if direction == 'right'
      setTimeout (->
        obj = $('#dot_' + id + 1)
        #console.log('in', obj);
        obj.attr 'r', new_r
        return
      ), 50 * 1
      setTimeout (->
        obj = $('#dot_' + id * 1 + 1)
        #console.log('out', obj);
        obj.attr 'r', 0
        return
      ), 300 + 50 * 1
    else if direction == 'left'
      setTimeout (->
        obj = $('#dot_' + id - 1)
        #console.log('in', obj);
        obj.attr 'r', new_r
        return
      ), 50 * 1
      setTimeout (->
        obj = $('#dot_' + id * 1 - 1)
        #console.log('out', obj);
        obj.attr 'r', 0
        return
      ), 300 + 50 * 1
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
      toggleActive: true
      orientation: 'bottom left'
      format: 'M dd, yyyy'
      container: $('.datePicker').parent()
      multidateSeparator: ' – ')

  state_is: (name) -> @rootScope.state_is(name)
  parse_diff: (diff_str) -> parseInt(diff_str)
  chart_changed: (chart) -> @rootScope.$state.go('projects.chart', {project: @project,slug: @project.slug,chart: @range[chart],from: @range.from,to: @range.to})
  toggle_debug: -> if @debug is true then @debug = false else @debug = true
@application.controller 'ChartController', ['$rootScope', '$scope', 'Projects', '$http', 'Translate', ChartController]
