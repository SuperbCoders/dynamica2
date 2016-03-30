class DashboardController
  constructor: (@rootScope, @scope, @Projects, @http) ->
    vm = @
    vm.params = @rootScope.$stateParams
    vm.project = {}
    vm.data = {}
    vm.range =
      date: undefined
      period: 'day'
      general_charts: undefined
      customer_charts: undefined
      product_charts: undefined
      chart: undefined

    vm.datepicker = $('.datePicker')

    @init_dashboard()
    @set_default_range()

    @scope.$watch('vm.range.period', (old_v, new_v) ->
      if new_v is '0'
        @set_default_range()
      vm.fetch()
    )

    @scope.$watch('vm.range.date',  (o, n) -> vm.fetch() if n )
    @scope.$watch('vm.range.chart', (o, n) -> vm.fetch() if n )

    @Projects.search({slug: vm.params.slug}).$promise.then( (project) ->
      vm.project = project
      vm.fetch()
    )

    #

  charts_fetch: (chart_type) ->
    vm = @

    chart_url = "/charts_data/#{chart_type}"
    chart_params =
      period: vm.range.period
      from: vm.range.raw_start.format('MM.DD.YYYY')
      to: vm.range.raw_end.format('MM.DD.YYYY')
      project_id: vm.project.id
      chart: vm.range.chart

    vm.http.get chart_url, params: chart_params

  fetch: ->
    return unless @project.id
    vm = @

    @charts_fetch('big_chart_data').success((response) ->
      vm.big_chart = response
      $('.areaChartFamily_1').each (ind) ->
        vm.init_area_family_chart($(this), response)

    )

    @charts_fetch('other_chart_data').success((response) ->
      vm.other_charts_data = response

      $('.areaChart_1').each (index) ->
        el_id = $(this).context.id
        vm.init_area_chart($(this), vm.avgBuilder(vm.other_charts_data[el_id]['data'], 11))

      $('.lineAreaChart_1').each (index) ->
        el_id = $(this).context.id
        vm.init_line_area_chart($(this), vm.other_charts_data[el_id])
    )

  # Draw block line area chart
  init_line_area_chart: (el, data) ->
    return if not data
    vm = @
    el.empty()
    margin =
      top: 0
      right: 0
      bottom: 0
      left: 0
    width = el.width() - (margin.left) - (margin.right)
    height = el.height() - (margin.top) - (margin.bottom)
    parseDate = d3.time.format(vm.getFormatOfDate()).parse
    x = d3.time.scale().range([0,width])
    y = d3.scale.linear().range([height,0])

    area_x = d3.time.scale().range([0,width])
    area_y = d3.scale.linear().range([height,0])
    area = d3.svg.area().x((d) ->
      area_x d.date
    ).y0(height).y1((d) ->
      area_y d.close
    )
    valueline = d3.svg.line().x((d) ->
      x d.date
    ).y((d) ->
      y d.close
    )
    #.interpolate("cardinal");
    svg = d3.select(el[0]).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
    t = $.extend(true, [], $('.dashboard').data('other_charts'))
#    data = t[el.attr('id')] or {}
    value = parseFloat(data['value']).number_with_delimiter('&thinsp;')
    if el.attr('id') == 'total_revenu'
      value += '&nbsp;' + data['value'].slice(-1)
    diff = parseFloat(data['diff']).number_with_delimiter('&thinsp;')
    diff += '&nbsp;%'
    value = if data['value'] == '' then '' else value
    diff = if data['diff'] == '' then '' else diff
    el.parent().parent().children('.graph-value').children('.val').html value
    el.parent().parent().children('.graph-value').children('.graph-dynamica').removeClass('dynamica_up dynamica_down').addClass if /-/g.test(data['diff']) then 'dynamica_down' else 'dynamica_up'
    el.parent().parent().children('.graph-value').children('.graph-dynamica').html diff

    for d in data['data']
      d.date = parseDate(d.date) if d.date
      d.close = +d.close

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
    svg.selectAll('dot').data(data['data']).enter().append('circle').attr('r', 5.5).attr('class', (d, i) ->
      cls = undefined
      if i == 0 or i == data['data'].length - 1
        cls = 'hidden'
      'mark ' + cls
    ).attr('cx', (d) ->
      x d.date
    ).attr 'cy', (d) ->
      y d.close

    return

  # Draw global chart
  init_area_family_chart: (el, data_files) ->
    vm = @
    el.find('svg').remove()
    legendBlock = el.parents('.graph-unit').find('.legend_v2')
    if !legendBlock.length
      legendBlock = $('<ul class="legend_v2 graph-unit-legend" />')
      el.parents('.graph-unit').append legendBlock

    dates = []
    values = []

    i = 0
    while i < data_files[0].data.length
      obj = data_files[0].data[i]
      dates.push moment(obj.date, vm.getFormatOfDateForMoment())
      values.push obj.close
      i++

    legendBlock.empty()

    tooltip = $('<table class="graph-tooltip-table" />')

    margin =
      top: 80
      right: 0
      bottom: 30
      left: 0
    width = el.width() - (margin.left) - (margin.right)
    height = el.height() - (margin.top) - (margin.bottom)
    parseDate = d3.time.format('%d-%b-%y').parse

    area_x = d3.time.scale().domain([
      moment.min(dates)
      moment.max(dates)
    ]).range([
      0
      width
    ])

    area_y = d3.scale.linear().domain([
      0
      1000 * Math.floor(Math.max.apply(null, values) / 1000 + 1)
    ]).range([
      height
      0
    ])

    area = d3.svg.area().x((d) ->
      area_x d.date
    ).y0(height).y1((d) ->
      area_y d.close
    ).interpolate('monotone')

    xAxis = d3.svg.axis().scale(area_x).ticks(dates.length - 1).tickFormat(d3.time.format('%b %d')).orient('bottom')

    svg = d3.select(el[0])
        .append('svg')
        .attr('width', width + margin.left + margin.right)
        .attr('height', height + margin.top + margin.bottom)
        .append('g')
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
    svg.append('g').attr('class', 'x axis family_x_axis').style('font-size', '14px').style('fill', '#fff').attr('transform', 'translate(0,' + height + ')').call xAxis
    i = 0
    while i < data_files.length
      data = data_files[i].data
      data.forEach (d) ->
        d.date = parseDate(d.date)
        d.close = +d.close
        return
      area_x.domain d3.extent(data, (d) ->
        d.date
      )
      area_y.domain [
        0
        d3.max(data, (d) ->
          d.close
        )
      ]
      svg.append('path').datum(data).attr('class', 'area area_v1').attr('id', 'family_area_' + i).attr('d', area).style('fill', (d) ->
        color = data_files[i].color
        legendItem = $('<li class="legend_item" />')
          .append($('<div class="legend_name" />')
          .css('color', color)
          .append($('<span/>').text(vm.translate_chart_name(data_files[i].tr_name)))
        ).append($('<div class="legend_val" />').append($('<span class="val" />').text(data_files[i].value))
          .append($('<sup class="graph-dynamica" />')
            .addClass(if /-/g.test(data_files[i].diff) then 'dynamica_down' else 'dynamica_up')
            .text(data_files[i].diff)))

        tooltip_item = $('<tr class="tooltip_row" />').attr('data-graph', 'family_area_' + i).append($('<td class="tooltip_name" />').append($('<div class="legend_name" />').css('color', color).append($('<span/>').text(data_files[i].name)))).append($('<td class="tooltip_val" />').append($('<b class="" />').text(data_files[i].value)))
        legendItem.attr('data-graph', '#family_area_' + i).on 'click', ->
          firedEl = $(this)
          graph = d3.select(firedEl.attr('data-graph'))
          tip = $('.tooltip_row[data-graph=' + graph.attr('id') + ']')
          graph_cls = graph.attr('class')
          if /hidden/g.test(graph_cls)
            firedEl.removeClass 'disabled'
            tip.removeClass 'disabled'
            graph.classed 'hidden', false
          else
            firedEl.addClass 'disabled'
            tip.addClass 'disabled'
            graph.classed 'hidden', true
          false
        tooltip.append tooltip_item
        legendBlock.append legendItem
        color
      ).style('opacity', .5).on 'mouseenter', ->

      i++
    i = 0
    while i < data_files.length
      svg.append('rect').attr('class', 'graph-hover-catcher hoverCatcher').attr('data-area', '#family_area_' + i).style('opacity', 0).attr('transform', 'translate(0,-' + margin.top + ')').attr('x', 0).attr('y', i * 100 / data_files.length + '%').attr('width', '100%').attr 'height', 100 / data_files.length + '%'
      i++
    return

  # Draw block chart #1
  init_area_chart: (el, data) ->
    return if not data
    el.empty()
    margin =
      top: 0
      right: 0
      bottom: 0
      left: 0
    width = el.width() - (margin.left) - (margin.right)
    height = el.height() - (margin.top) - (margin.bottom)
    parseDate = d3.time.format('%d-%b-%y').parse
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
    )
    svg = d3.select(el[0]).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

    for d in data
      d.date = parseDate(d.date)
      d.close = +d.close

    area_x.domain d3.extent(data, (d) ->
      d.date
    )
    area_y.domain [
      0
      d3.max(data, (d) ->
        d.close
      )
    ]
    gradient = svg.append('svg:defs').append('svg:linearGradient').attr('id', 'area_gradient_1').attr('x1', '0%').attr('y1', '0%').attr('x2', '0%').attr('y2', '100%').attr('spreadMethod', 'pad')
    gradient.append('svg:stop').attr('offset', '0%').attr('stop-color', '#dfe7ff').attr 'stop-opacity', 1
    gradient.append('svg:stop').attr('offset', '100%').attr('stop-color', '#f6f6f6').attr 'stop-opacity', 0
    svg.append('path').datum(data).attr('class', 'area area_v1').attr('d', area).style 'fill', 'url(#area_gradient_1)'

    return

  set_default_range: ->
    vm = @
    today = moment()
    vm.range.raw_start = rangeStart = moment(today).startOf('month')
    vm.range.raw_end = rangeEnd = moment(today).endOf('month')
    vm.range.from = rangeStart.format('MM.DD.YYYY')
    vm.range.to = rangeEnd.format('MM.DD.YYYY')

    vm.set_datepicker_date(rangeStart, rangeEnd)

  chart_changed: (chart) ->
    @rootScope.$state.go('projects.chart', {
      project: @project
      slug: @project.slug
      chart: @range[chart]
      from: @range.from
      to: @range.to
    })

  getFormatOfDate: ->
    return '%d-%b-%y'
    switch @range.period
      when 'day'
        return '%d-%b-%y'
      when 'week'
        return '%V-%g'
      when 'month'
        return '%b-%y'
    return

  avgBuilder: (arr, step) ->
    ret = []
    part = 1 * (arr.length / step).toFixed(0)
    if part < 2
      return arr
    i = 0
    while i < arr.length
      obj = arr.slice(i, i + (if arr.length - (part * 2) >= i then part else arr.length))
      val = 0
      j = 0
      while j < obj.length
        val += 1 * obj[j].close
        j++
      ret.push
        'close': 1 * (val / obj.length).toFixed(0)
        'date': arr[i].date
      val = 0
      if !(arr.length - (part * 2) >= i)
        break
      i += part
    ret

  getFormatOfDateForMoment: ->
    switch @range.period
      when 'day'
        return 'DD-MMM-YY'
      when 'week'
        return 'WW-GG'
      when 'month'
        return 'MMM-YY'
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

  fit2Limits: (pckr, date, max) ->
    start = moment(pckr.datepicker('getStartDate'))
    end = moment(pckr.datepicker('getEndDate'))
    if max
      moment.max(start, date).startOf('day')._d
    else
      moment.min(end, date).startOf('day')._d

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

    vm.scope.$on('$destroy', -> $('.page').removeClass('dashboard_page') )

    vm.datepicker.datepicker(
      multidate: 2
      startDate: '-477d'
      endDate: '0'
      toggleActive: true
      orientation: 'bottom left'
      format: 'M dd, yyyy'
      container: $('.datePicker').parent()
      multidateSeparator: ' – ')

  translate_chart_name: (name) ->
    names_ru =
      revenue: 'Выручка'
      orders: 'Заказы'
      products_sell: 'Товаров продано'
      unic_users: 'Посетителей'
      customers: 'Клиентов'
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
      revenue: 'Revenue'
      orders: 'Orders'
      products_sell: 'Products sell'
      unic_users: 'Unic users'
      customers: 'Customers'
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

  parse_diff: (diff_str) -> parseInt(diff_str)
  toggle_debug: -> if @debug is true then @debug = false else @debug = true
@application.controller 'DashboardController', ['$rootScope', '$scope', 'Projects', '$http', DashboardController]

