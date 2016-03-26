class DashboardController
  constructor: (@rootScope, @scope, @Projects, @Charts, @http) ->
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

    @scope.$watch('vm.range.period', (old_v, new_v) ->
      if new_v is '0'
        today = moment()
        vm.range.raw_start = rangeStart = moment(today).startOf('month')
        vm.range.raw_end   = rangeEnd = moment(today).endOf('month')

        vm.datepicker.datepicker('setDates', [
          vm.fit2Limits(vm.datepicker, rangeStart, true)
          vm.fit2Limits(vm.datepicker, rangeEnd)
        ]).datepicker 'update'

      vm.fetch()
    )

    @scope.$watch('vm.range.date',  (o, n) -> vm.fetch() if n )
    @scope.$watch('vm.range.chart', (o, n) -> vm.fetch() if n )

    @scope.$on('$destroy', -> $('.page').removeClass('dashboard_page') )

    @Projects.search({slug: vm.params.slug}).$promise.then( (project) ->
      vm.project = project
      vm.Charts.project = vm.project
      vm.Charts.range = vm.range
    )


  # - - - - - - - - - - - - - - - - CUT HERE - - - - - - - - - - - - - - -
  charts_fetch: (chart_type) ->
    vm = @

    chart_url = "/charts_data/#{chart_type}"
    chart_params =
      period: vm.range.period
      from: vm.range.raw_start.format('DD-MM-YYYY')
      to: vm.range.raw_end.format('DD-MM-YYYY')
      project_id: vm.project.id
      chart: vm.range.chart

    vm.http.get chart_url, params: chart_params

  fetch: ->
    return unless @project.id
    vm = @
    @charts_fetch('big_chart_data').success((response) ->
      vm.data = response
      $('.areaChartFamily_1').each (ind) -> vm.init_area_family_chart($(this), vm.data)
    )


    @charts_fetch('other_chart_data').success((response) ->
      vm.other_charts_data = response
    )

  init_line_area2_chart: (el, data) ->
    el.empty()
    margin =
      top: 0
      right: 0
      bottom: 0
      left: 0
    width = el.width() - (margin.left) - (margin.right)
    height = el.height() - (margin.top) - (margin.bottom)

    scale =
      x: d3.scale.linear().domain([
        0
        data.length
      ]).range([
        0
        width
      ])
      y: d3.scale.linear().domain([
        0
        d3.max(data)
      ]).range([
        height
        15
      ])
    chart = d3.select(el[0]).append('svg:svg').data([ data ]).attr('width', width).attr('height', height).append('svg:g')
    line = d3.svg.area().x((d, i) ->
      scale.x i
    ).y((d) ->
      scale.y d
    ).y0(height).interpolate('cardinal')
    gradient = chart.append('svg:defs').append('svg:linearGradient').attr('id', 'area_gradient_1').attr('x1', '0%').attr('y1', '0%').attr('x2', '0%').attr('y2', '100%').attr('spreadMethod', 'pad')
    gradient.append('svg:stop').attr('offset', '0%').attr('stop-color', '#dfe7ff').attr 'stop-opacity', 1
    gradient.append('svg:stop').attr('offset', '100%').attr('stop-color', '#f6f6f6').attr 'stop-opacity', 0
    chart.append('svg:path').attr('d', (d, i) ->
      line d, i
    ).style 'fill', 'url(#area_gradient_1)'
    chart.selectAll('circle.mark').data(data).enter().append('svg:circle').attr('class', 'mark').attr('cx', (d, i) ->
      scale.x i
    ).attr('cy', (d) ->
      scale.y d
    ).attr 'r', 5.5
    return

  init_line_chart: (el, data) ->
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
    x = d3.time.scale().range([
      0
      width
    ])
    y = d3.scale.linear().range([
      height
      0
    ])
    valueline = d3.svg.line().x((d) ->
      x d.date
    ).y((d) ->
      y d.close
    )
    svg = d3.select(el[0]).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

    # Get the data
    for d in data
      d.date = parseDate(d.date)
      d.close = +d.close

    # Scale the range of the data
    x.domain d3.extent(data, (d) ->
      d.date
    )
    y.domain [
      0
      d3.max(data, (d) ->
        Math.max d.close
      )
    ]
    svg.append('path').attr('class', 'line').attr('id', 'blueLine').attr 'd', valueline(data)
    return

  init_line_area_chart: (el) ->
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
      #console.log(d);
      x d.date
    ).y((d) ->
      #console.log(d);
      y d.close
    )
    #.interpolate("cardinal");
    svg = d3.select(el[0]).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
    t = $.extend(true, [], $('.dashboard').data('other_charts'))
    data = t[el.attr('id')] or {}
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
    data = data['data'] or []
    # Get the data
    data.forEach (d) ->
      d.date = parseDate(d.date)
      d.close = +d.close
      return
    # Scale the range of the data
    x.domain d3.extent(data, (d) ->
      d.date
    )
    y.domain [
      0
      d3.max(data, (d) ->
        Math.max d.close
      )
    ]
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
    svg.append('path').attr('class', 'line').attr 'd', valueline(data)
    svg.append('path').datum(data).attr('class', 'area area_v1').attr('d', area).style 'fill', 'url(#area_gradient_1)'
    # Add the scatterplot
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


  getFormatOfDateForMoment: ->
    switch @range.period
      when 'day'
        return 'DD-MMM-YY'
      when 'week'
        return 'WW-GG'
      when 'month'
        return 'MMM-YY'
    return

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
#    .on('mousemove', (d) ->
#      `var i`
#      `var tooltip`
#      #console.log(d3.mouse(this));
#      tooltip = d3.select('#tooltip')
#      tooltip_content = $('#tooltip_content')
#      tooltip_dot = $('#tooltip_dot')
#      tool_table = $('<table class="graph-tooltip-table" />')
#      distance = area_x(data_files[activeFamilyGraph].data[0].date) - area_x(data_files[activeFamilyGraph].data[1].date) or 0
#      x = d3.mouse(this)[0] + distance / 2
#      x0 = area_x.invert(x)
#      ind = undefined
#      while k < dates.length
#        obj1 = dates[k]
#        if moment(x0).startOf('day').isSame(obj1, 'day')
#          ind = k
#          break
#        k++
#      while j < data_files.length
#        color = data_files[j].color
#        data = data_files[j].data
#        #var i = bisectDate(data, x0, 1);
#        tooltip_item = $('<tr class="tooltip_row" />').attr('data-graph', 'family_area_' + j).addClass(if j == activeFamilyGraph then 'active_row' else '').addClass(if $('.graph-unit-legend .legend_item[data-graph=#family_area_' + j + ']').hasClass('disabled') then 'disabled' else '').append($('<td class="tooltip_name" />').append($('<div class="legend_name" />').css('color', color).append($('<span/>').text(data_files[j].name)))).append($('<td class="tooltip_val" />').append($('<b class="" />').text(data_files[j].data[ind].close)))
#        tool_table.append tooltip_item
#        j++
#      tooltip_content.empty().append($('<div class="tooltip-title" />').text(moment(x0).format('dddd, D MMMM YYYY'))).append tool_table
#      tooltip.classed('flipped_left', x < tooltip_content.outerWidth() + 25).style 'left', area_x(data_files[activeFamilyGraph].data[ind].date) + 'px'
#      tooltip_dot.css 'top', margin.top + area_y(data_files[activeFamilyGraph].data[ind].close) - 11
#      return
#    )
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

  init_area_chart: (el, data) ->
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

  init_donut_chart: (el, data) ->
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
    svg = d3.select(el[0]).append('svg').attr('width', width).attr('height', height).append('g').attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')')
    svg.selectAll('.arc').data(data).enter().append('g').attr('class', 'arc')
#    d3.csv 'customers_data.csv', type, (error, data) ->
#      if error
#        throw error
#      g = svg.selectAll('.arc').data(pie(data)).enter().append('g').attr('class', 'arc')
#      g.append('path').attr('d', arc).style 'fill', (d) ->
#        color = d.data.color
#        legendItem = $('<li class="legend_item" />').append($('<div class="legend_name" />').css('color', color).append($('<span/>').text(d.data.name))).append($('<div class="legend_val" />').text(d.data.value))
#        el.next().append legendItem
#        color
#      return
    return

  chart_changed: (chart_type) ->
    value = @range[chart_type]
    @range.general_charts = undefined
    @range.customer_charts = undefined
    @range.product_charts = undefined
    @range[chart_type] = value
    @range.chart = @range[chart_type]

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

    vm.datepicker.datepicker('setDates', [
      vm.fit2Limits(vm.datepicker, rangeStart, true)
      vm.fit2Limits(vm.datepicker, rangeEnd)
    ]).datepicker 'update'

    console.log 'Range type changed'
    return

  fit2Limits: (pckr, date, max) ->
    start = moment(pckr.datepicker('getStartDate'))
    end = moment(pckr.datepicker('getEndDate'))
    if max
      moment.max(start, date).startOf('day')._d
    else
      moment.min(end, date).startOf('day')._d

  init_dashboard: ->
    vm = @
    $('.selectpicker').selectpicker({size: 70, showTick: false, showIcon: false})
    $('.page').addClass('dashboard_page')

    today = moment()
    vm.datepicker.datepicker(
      multidate: 2
      startDate: '-477d'
      endDate: '0'
      toggleActive: true
      orientation: 'bottom left'
      format: 'M dd, yyyy'
      container: $('.datePicker').parent()
      multidateSeparator: ' – ')




#        beforeShowDay: (date, e) ->
#          dataPicker = $(e.picker)
#          dPickerElement = $(e.element)
#          dates = e.dates
#          curDate = moment(date)
#          rangeStart = moment(dates[0])
#          rangeEnd = moment(dates[1])
#          if rangeStart.isAfter(rangeEnd)
#            dPickerElement.datepicker('setDates', [
#              e.dates[1]
#              e.dates[0]
#            ]).datepicker 'update'
#          if dates.length == 1
#            if curDate.isSame(rangeStart, 'day')
#              return 'start-range'
#          if dates.length == 2
#            if rangeStart.isAfter(rangeEnd, 'day')
#              rangeStart = [
#                rangeEnd
#                rangeEnd = rangeStart
#              ][0]
#            if curDate.isSame(rangeStart, 'day')
#              return 'start-range'
#            if curDate.isSame(rangeEnd, 'day')
#              return 'end-range'
#            if curDate.isBetween(rangeStart, rangeEnd)
#              return 'in-range'
#          if dates.length == 3
#            dPickerElement.datepicker('setDates', [ dates[2] ]).datepicker 'update'
#          return
#      ).on('show', (e) ->
#        calendar = $('.datepicker.datepicker-dropdown.dropdown-menu')
#        if calendar.find('.btn').length
#          return
#        buttonPane = $('<span class="calendar-control-holder" />')
#        setTimeout (->
#          btn = $('<a class="apply-calendar-btn_ btn btn-block btn-danger" >Показать</a>')
#          btn.off('click').on 'click', ->
#            fetchData()
#            false
#          buttonPane.appendTo calendar
#          btn.appendTo buttonPane
#          return
#        ), 1
#        return
#      ).on 'changeDate', (e, w) ->
#        return

#    $('.graphFilterDate').on('change', ->
#      console.log 'changed'
#      firedEl = $(this)
#      datePckr = firedEl.closest('.datepickerComponent').find('.datePicker')
#      rangeStart = undefined
#      rangeEnd = undefined
#      newRange = firedEl.val()
#      today = moment()
#      if $('.dashboard').data('date-from') and $('.dashboard').data('date-to')
#        rangeStart = moment($('.dashboard').data('date-from'))
#        rangeEnd = moment($('.dashboard').data('date-to'))
#        $('.dashboard').data 'date-to', null
#
#        console.log "Date from #{rangeStart}"
#        console.log "Date to #{rangeEnd}"
#      else
#        if newRange == 0
#          #  Current month
#          rangeStart = moment(today).startOf('month')
#          rangeEnd = moment(today).endOf('month')
#        else if newRange == 1
#          #  Previous month
#          rangeStart = moment(today).subtract(1, 'month').startOf('month')
#          rangeEnd = moment(today).subtract(1, 'month').endOf('month')
#        else if newRange == 2
#          #  Last 3 month
#          rangeStart = moment(today).subtract(3, 'month')
#          rangeEnd = moment(today)
#        else if newRange == 3
#          #  Last 6 month
#          rangeStart = moment(today).subtract(6, 'month')
#          rangeEnd = moment(today)
#        else if newRange == 4
#          #  Last year
#          rangeStart = moment(today).subtract(12, 'month')
#          rangeEnd = moment(today)
#        else if newRange == 5
#          #  All time
#          rangeStart = moment(datePckr.datepicker('getStartDate'))
#          rangeEnd = moment(datePckr.datepicker('getEndDate'))

#      datePckr.datepicker('setDates', [
#        vm.fit2Limits(datePckr, rangeStart, true)
#        vm.fit2Limits(datePckr, rangeEnd)
#      ]).datepicker 'update'
#      if $('.datePicker').datepicker('getDates').length == 2
#        console.log 'Fetching'
#      return
#    ).change()


@application.controller 'DashboardController', ['$rootScope', '$scope', 'Projects', 'Charts', '$http', DashboardController]

