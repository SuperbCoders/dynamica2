class DashboardController
  constructor: (@rootScope, @scope, @Projects, @http, @filter, @localStorage) ->
    vm = @
    vm.params = @rootScope.$stateParams
    vm.project = {}
    vm.datepicker = $('.datePicker')
    vm.date_range = 0
    vm.range =
      date: undefined
      period: 'day'
      general_charts: undefined
      customer_charts: undefined
      product_charts: undefined
      chart: undefined

    @rootScope.current_vm = vm

    @init_dashboard()

    # Try to load rangs from LS
    @rootScope.load_dates_from_ls(vm)

    if not vm.range.from and not vm.range.to
      console.log 'Setting default dates'
      console.log vm.range
      # Set range to month start and end
      vm.range.raw_start = rangeStart = moment().startOf('month')
      vm.range.raw_end = rangeEnd = moment().endOf('month')
      vm.range.from = rangeStart.format('MM.DD.YYYY')
      vm.range.to = rangeEnd.format('MM.DD.YYYY')

    # Day, Week, Month
    @scope.$watch('vm.range.period', (old_v, new_v) -> vm.fetch())
    @scope.$watch('vm.range.date',  (o, n) -> vm.fetch() if n )
    @scope.$watch('vm.range.chart', (o, n) -> vm.fetch() if n and n != 'products_revenue' )

    @Projects.search({slug: vm.params.slug}).$promise.then( (project) ->
      vm.project = project
      vm.rootScope.current_project(vm.project)
      vm.rootScope.currency = vm.project.currency
      vm.rootScope.set_datepicker_start_date(vm.datepicker, vm.project.first_project_data)
      vm.rootScope.set_datepicker_date(vm.datepicker, vm.range.raw_start, vm.range.raw_end)
    )

  datepicker_changed: ->
    vm = @
    dates = vm.datepicker_date.split(' – ')
    if dates.length == 2
      vm.range.raw_start = moment(dates[0], "MMM D, YYYY")
      vm.range.raw_end = moment(dates[1], "MMM D, YYYY")
      vm.range.from = vm.range.raw_start.format('MM.DD.YYYY')
      vm.range.to = vm.range.raw_end.format('MM.DD.YYYY')
      vm.fetch()

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

      # Retrieve top 5 products
      vm.top_5_products = info['top'] for info in vm.big_chart when info['tr_name'] == 'products_sell'

      # Draw general graph
      $('.areaChartFamily_1').each (ind) -> vm.draw_general_graph($(this), response)
    )

    @charts_fetch('other_chart_data').success((response) ->
      vm.other_charts_data = response

      $('.areaChart_1').each (index) ->
        el_id = $(this).context.id
        vm.init_area_chart($(this), vm.avgBuilder(vm.other_charts_data[el_id]['data'], 11))

      $('.lineAreaChart_1').each (index) ->
        el_id = $(this).context.id
        vm.draw_block_charts($(this), vm.other_charts_data[el_id])

      $('.donutChart_1').each (index) ->
        el_id = $(this).context.id
        if el_id in ['new_and_repeat_customers_number', 'order_statuses']
          vm.init_donut_chart($(this), vm.other_charts_data[el_id])
    )

  # Draw block line area chart
  # график с точками
  draw_block_charts: (el, data) ->
    return if not data
    if data['data'].length <= 0
      # Иногда бывает что бэкенд не возвращает данные, поэтому некоторые
      # графики на дашборде могут пустовать. Для этого мы добавляем 10 дат с
      # 0-ыми данными
      a = moment('2013-01-01')
      b = moment('2013-01-11')
      m = moment(a)
      while m.isBefore(b)
        # 12-Feb-16
        data['data'].push {date: m.format('DD-MMM-YY'), close: 0}
        m.add 'days',1


    vm = @
    el.empty()
    chart_name = element_id = el.attr('id')

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

    svg = d3.select(el[0])
      .append('svg')
      .attr('width', width + margin.left + margin.right)
      .attr('height', height + margin.top + margin.bottom)
      .append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

    t = $.extend(true, [], $('.dashboard').data('other_charts'))
    value = parseFloat(data['value'])
    diff = parseFloat(data['diff'])

    currency_elements = ['total_gross_revenues', 'average_order_value', 'average_revenue_per_customer', 'total_gross_delivery']

    if element_id in currency_elements
      value = vm.filter('dynCurrency')(value)
    else
      value = 0 if value is 'NaN'

    el.parent().parent().children('.graph-value').children('.val').html value
    el.parent().parent().children('.graph-value').children('.graph-dynamica').removeClass('dynamica_up dynamica_down').addClass if /-/g.test(data['diff']) then 'dynamica_down' else 'dynamica_up'
    el.parent().parent().children('.graph-value').children('.graph-dynamica').html diff

    data['data'] = vm.avgBuilder(data['data'], 10)

    not_null = false
    TOP_VALUE = 0
    for d in data['data']
      not_null = true if d.close > 0
      TOP_VALUE = d.close if d.close > TOP_VALUE
      # Parse 16-Feb-16
      if d.date and d.date.length == 9
        d.date = parseDate(d.date)
      d.close = +d.close

    x.domain d3.extent(data['data'], (d) -> d.date )
    area_x.domain d3.extent(data['data'], (d) -> d.date)

    if not_null
#      y.domain [
#        0
#        d3.max(data['data'], (d) ->
#          if d.close == 0
#            (TOP_VALUE / 100) * 10
#          else
#            Math.max d.close
#        )
#      ]
#      area_y.domain [
#        0
#        d3.max(data['data'], (d) ->
#          if d.close == 0
#            (TOP_VALUE / 100) * 10
#          else
#            d.close
#        )
#      ]

      y.domain [
        0
        d3.max(data['data'], (d) ->
          Math.max d.close
        )
      ]
      area_y.domain [
        0
        d3.max(data['data'], (d) ->
          d.close
        )
      ]
    else
      y.domain [
        0, 100
      ]
      area_y.domain [
        0, 100
      ]

    if !not_null
      for d, index in data['data']
        d.close = 8
    else
      for d, index in data['data']
        if d.close == 0
          d.close = (TOP_VALUE/100) * 10

    gradient = svg
      .append('svg:defs')
      .append('svg:linearGradient')
      .attr('id', 'area_gradient_1')
      .attr('x1', '0%')
      .attr('y1', '0%')
      .attr('x2', '0%')
      .attr('y2', '100%')
      .attr('spreadMethod', 'pad')

    gradient.append('svg:stop')
      .attr('offset', '0%')
      .attr('stop-color', '#dfe7ff')
      .attr('stop-opacity', 1)

    gradient.append('svg:stop')
      .attr('offset', '100%')
      .attr('stop-color', '#f6f6f6')
      .attr('stop-opacity', 0)

    svg.append('path')
      .attr('class', 'line line_v2')
      .attr('d', valueline(data['data']))

    svg.append('path')
      .datum(data['data'])
      .attr('class', 'area area_v2')
      .attr('d', area).style 'fill', 'url(#area_gradient_1)'

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

  draw_general_graph: (el, data_files) ->
    vm = @
    `var i`
    `var i`

    # Clear dashbord from svg
    el.find('svg').remove()

    legendBlock = el.parents('.graph-unit').find('.legend_v2')
    legendBlock.empty()

    dates = []
    values = []

    i = 0
    while i < data_files[0].data.length
      obj = data_files[0].data[i]
      dates.push moment(obj.date, "DD-MMM-YY")
      values.push obj.close
      i++

    tooltip = $('<table class="graph-tooltip-table" />')
    margin =
      top: 80
      right: 0
      bottom: 30
      left: 0

    width = el.width() - (margin.left) - (margin.right)
    height = el.height() - (margin.top) - (margin.bottom)
    bisectDate = d3.bisector((d) ->
      d.date
    ).left
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


    start_date = moment(dates[0])
    end_date = moment(dates[DATA_LENGTH - 1])

    DATA_LENGTH = dates.length
    DATA_DAYS = end_date.diff(start_date, 'days')
    DATA_GROUP = vm.range.period

    switch DATA_GROUP
      when 'day', 'week'
        DATE_FORMAT = '%b %d'
        TICKS = 10

        if DATA_GROUP is 'day' and DATA_DAYS in [100..200]
          TICKS = 15

        if DATA_GROUP is 'day' and DATA_DAYS > 365
          DATE_FORMAT = '%b %d %y'

        if DATA_GROUP is 'week' and DATA_DAYS > 15
          DATE_FORMAT = '%b %d %y'
          TICKS = 12

      when 'month'
        TICKS = 10
        DATE_FORMAT = '%b %d %y'

    xAxis = d3.svg.axis().scale(area_x).ticks(TICKS).tickFormat(d3.time.format(DATE_FORMAT)).orient('bottom')
    #var xScale = d3.scale.ordinal()
    #    .domain(d3.range(dataset.length))
    #    .rangeRoundBands([0, w], 0.05);

    svg = d3.select(el[0]).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')').on('mousemove', (d) ->
      `var tooltip`
      tooltip = d3.select('#tooltip')
      tooltip_content = $('#tooltip_content')
      tooltip_dot = $('#tooltip_dot')
      tool_table = $('<table class="graph-tooltip-table" />')

      if data_files[vm.activeFamilyGraph].data.length > 0
        distance = area_x(data_files[vm.activeFamilyGraph].data[0].date) - area_x(data_files[vm.activeFamilyGraph].data[1].date) or 0
      else
        distance = 0
      x = d3.mouse(this)[0] + distance / 2
      x0 = area_x.invert(x)
      ind = undefined
      k = 0

      while k < dates.length
        obj1 = dates[k]
        if moment(x0).startOf('day').isSame(obj1, 'day')
          ind = k
          break
        k++
      j = 0

      while j < data_files.length
        color = data_files[j].color
        data = data_files[j].data

        tooltip_item = $('<tr class="tooltip_row" />')
          .attr('data-graph', 'family_area_' + j)
          .addClass(if j == vm.activeFamilyGraph then 'active_row' else '')
          .addClass(if $('.graph-unit-legend .legend_item[data-graph=#family_area_' + j + ']').hasClass('disabled') then 'disabled' else '')
          .append($('<td class="tooltip_name" />')
          .append($('<div class="legend_name" />')
          .css('color', color)
          .append($('<span/>')
          .text(data_files[j].name))))
          .append($('<td class="tooltip_val" />').append($('<b class="" />').text(if data_files[j].data[ind] then data_files[j].data[ind].close else 0)))

        tool_table.append tooltip_item
        j++

      tooltip_content.empty()
        .append($('<div class="tooltip-title" />')
        .text(moment(x0).format('dddd, D MMMM YYYY')))
        .append(tool_table)

      tooltip.classed('flipped_left', x < tooltip_content.outerWidth() + 25)
        .style('left', area_x(data_files[vm.activeFamilyGraph].data[ind].date) + 'px')

      tooltip_dot.css 'top', margin.top + area_y(data_files[vm.activeFamilyGraph].data[ind].close) - 11
      return
    )
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
        legendItem = $('<li class="legend_item" />').append($('<div class="legend_name" />').css('color', color).append($('<span/>').text(data_files[i].name))).append($('<div class="legend_val" />').append($('<span class="val" />').text(data_files[i].value)).append($('<sup class="graph-dynamica" />').addClass(if /-/g.test(data_files[i].diff) then 'dynamica_down' else 'dynamica_up').text(data_files[i].diff)))
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

  init_donut_chart: (el, data) ->

    chart_name = element_id = el.attr('id')

    type = (d) ->
      d.value = +d.value
      d

    el.empty()
    legendBlock = el.parent().find('.legend_v1')
    if !legendBlock.length
      legendBlock = $('<ul class="legend_v1" />')
      el.after legendBlock
    legendBlock.empty()
    width = el.width()
    height = el.height()
    radius = Math.min(width, height) / 2
    arc = d3.svg.arc().outerRadius(radius).innerRadius(radius - 10)
    pie = d3.layout.pie().sort(null).value((d) ->
      d.value
    )
    svg = d3.select(el[0]).append('svg')
      .attr('width', width)
      .attr('height', height)
      .append('g')
      .attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')')

    g = svg.selectAll('.arc').data(pie(data['data'])).enter().append('g').attr('class', 'arc')
    g.append('path').attr('d', arc).style 'fill', (d) ->
      color = d.data.color
      legendItem = $('<li class="legend_item" />').append($('<div class="legend_name" />').css('color', color).append($('<span/>').text(d.data.name))).append($('<div class="legend_val" />').text(d.data.value))
      el.next().append legendItem
      color
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
    svg = d3.select(el[0])
      .append('svg')
      .attr('width', width + margin.left + margin.right)
      .attr('height', height + margin.top + margin.bottom)
      .append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

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
    gradient = svg.append('svg:defs')
      .append('svg:linearGradient')
      .attr('id', 'area_gradient_1')
      .attr('x1', '0%')
      .attr('y1', '0%')
      .attr('x2', '0%')
      .attr('y2', '100%')
      .attr('spreadMethod', 'pad')

    gradient.append('svg:stop')
      .attr('offset', '0%')
      .attr('stop-color', '#dfe7ff')
      .attr('stop-opacity', 1)

    gradient.append('svg:stop')
      .attr('offset', '100%')
      .attr('stop-color', '#f6f6f6')
      .attr('stop-opacity', 0)

    svg.append('path')
      .datum(data)
      .attr('class', 'area area_v1')
      .attr('d', area)
      .style('fill', 'url(#area_gradient_1)')

    svg.selectAll('dot').data(data).enter().append('circle').attr('r', 5.5).attr('class', (d, i) ->
      cls = undefined
      if i == 0 or i == data.length - 1
        cls = 'hidden'
      'mark ' + cls
    ).attr('cx', (d) ->
      x d.date
    ).attr 'cy', (d) ->
      y d.close
    return

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

  # Called when user change presetted date ranges ( Current month, prev month, 3 month etc )
  set_date_range: (range_type) ->
    vm = @
    return if range_type not in ["0","1","2","3","4","5","6"]
    return if not vm.datepicker

    vm.rootScope.set_date_range(vm.range, parseInt(range_type))
    vm.rootScope.set_datepicker_date(vm.datepicker, vm.range.raw_start, vm.range.raw_end)
    vm.fetch()
    return

  init_dashboard: ->
    vm = @
    $('.selectpicker').selectpicker({size: 70, showTick: false, showIcon: false})
    $('.page').addClass('dashboard_page')

    vm.scope.$on('$destroy', -> $('.page').removeClass('dashboard_page') )

    vm.datepicker.datepicker(
      multidate: 3
      toggleActive: true
      orientation: 'bottom left'
      format: 'M dd, yyyy'
      container: $('.datePicker').parent()
      multidateSeparator: ' – '
      beforeShowDay: (date, e) ->
        dataPicker = $(e.picker)
        dPickerElement = $(e.element)
        dates = e.dates
        curDate = moment(date)
        rangeStart = moment(dates[0])
        rangeEnd = moment(dates[1])
        if rangeStart.isAfter(rangeEnd)
          dPickerElement.datepicker('setDates', [
            e.dates[1]
            e.dates[0]
          ]).datepicker 'update'

        if dates.length == 1
          if curDate.isSame(rangeStart, 'day')
            return 'start-range'

        if dates.length == 2
          if rangeStart.isAfter(rangeEnd, 'day')
            rangeStart = [
              rangeEnd
              rangeEnd = rangeStart
            ][0]
          if curDate.isSame(rangeStart, 'day')
            return 'start-range'
          if curDate.isSame(rangeEnd, 'day')
            return 'end-range'
          if curDate.isBetween(rangeStart, rangeEnd)
            return 'in-range'

        if dates.length == 3
          dPickerElement.datepicker('setDates', [ dates[2] ]).datepicker 'update'
        return
      )


    $('body').delegate('.hoverCatcher', 'mouseenter', ->
        firedEl = $($(this).attr('data-area'))
        vm.activeFamilyGraph = $(this).attr('data-area').replace(/\D/g, '') * 1
        firedEl.css('opacity', 1).siblings('.area').css 'opacity', .15
        return
      ).delegate '.hoverCatcher', 'mouseleave', ->
        firedEl = $($(this).attr('data-area'))
        firedEl.css('opacity', .5).siblings('.area').css 'opacity', .5
        return

  state_is: (name) -> @rootScope.state_is(name)
  parse_diff: (diff_str) -> parseInt(diff_str)
  toggle_debug: -> if @debug is true then @debug = false else @debug = true

@application.controller 'DashboardController', ['$rootScope', '$scope', 'Projects', '$http', '$filter', 'localStorageService', DashboardController]

