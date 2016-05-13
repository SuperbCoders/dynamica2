#= require jquery.min.js
#= require jquery.placeholder.min.js
#= require moment
#= require lodash/lodash
#= require select2
#= require bootstrap.min.js
#= require angular
#= require angular-ui-router
#= require d3

getFormatOfDate = ->
  return '%d-%b-%y'

avgBuilder = (arr, step) ->
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

draw_general_graph = (el, data) ->
  return if data['data'].length < 1

  chart_name = element_id = el.attr('id')

  vm = @
  dates = []
  values = []
  i = 0


  `var i`

  make_y_axis = -> d3.svg.axis().scale(y).orient('left').ticks 5
  make_x_axis = -> d3.svg.axis().scale(x).orient('bottom').ticks 5

  el.find('svg').remove()

  data = data['data']

  for d in data
    dates.push moment(d.date)
    values.push d.close

  margin =
    top: 30
    right: 35
    bottom: 50
    left: 100

  width = el.width() - (margin.left) - (margin.right)
  height = el.height() - (margin.top) - (margin.bottom)
  tooltip = $('#tooltip')
  tooltip_content = $('#tooltip_content')
  bisectDate = d3.bisector((d) ->
    d.date
  ).left
  parseDate = d3.time.format('%d-%b-%y').parse

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


  start_date = moment(dates[0])
  end_date = moment(dates[DATA_LENGTH - 1])

  DATA_LENGTH = dates.length
  DATA_DAYS = end_date.diff(start_date, 'days')
  DATA_GROUP = 'week'
  DATE_FORMAT = d3.time.format('%b %d')
  TICKS = 7


  xAxis = d3.svg.axis()
    .scale(x)
    .ticks(TICKS)
    .tickFormat(DATE_FORMAT)
    .orient('bottom')

  yAxis = d3.svg.axis().scale(y).ticks(5).tickFormat((d) ->
    if d == 0 then '' else d
  ).orient('left')

  svg = d3.select(el[0])
    .append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top + margin.bottom)
    .append('g')
    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')


  svg.append('g')
    .attr('class', 'x axis')
    .style('font-size', '14px')
    .style('fill', '#A5ADB3')
    .attr('transform', 'translate(0,' + height + ')').call xAxis

  svg.append('g')
    .attr('class', 'y axis')
    .attr('transform', 'translate(' + -25 + ', 0)')
    .style('font-size', '14px')
    .style('fill', '#A5ADB3').attr('class', 'grid').call yAxis

  svg.append('g')
    .attr('class', 'gray_grid')
    .call make_y_axis().tickSize(-width, 0, 0).tickFormat('')


  # Get the data
  for d in data
    d.date = parseDate(d.date)
    d.close = Math.round(+d.close)

  # Scale the range of the data
  x.domain d3.extent(data, (d) -> d.date)
  area_x.domain d3.extent(data, (d) -> d.date)

  y.domain [ 0,d3.max(data, (d) -> Math.max d.close) ]
  area_y.domain [ 0, d3.max(data, (d) -> d.close)]

  svg.append('path').attr('class', 'line line_v2').attr 'd', valueline(data)

  gradient = svg.append("svg:defs")
    .append("svg:linearGradient")
    .attr("id", "area_gradient_1")
    .attr("x1", "0%")
    .attr("y1", "0%")
    .attr("x2", "0%")
    .attr("y2", "100%")
    .attr("spreadMethod", "pad")

  gradient.append("svg:stop")
    .attr("offset", "0%")
    .attr("stop-color", "#dfe7ff")
    .attr("stop-opacity", 1)

  gradient.append("svg:stop")
    .attr("offset", "100%")
    .attr("stop-color", "#f6f6f6")
    .attr("stop-opacity", 0)

  svg.append("path")
    .datum(data)
    .attr("class", "area area_v1")
    .attr("d", area)
    .style("fill", 'url(#area_gradient_1)')

  svg.append("path")
    .attr("class", "line")
    .attr("d", valueline(data))

  # Add the scatterplot
  svg.append('line')
    .attr('id', 'line_for_dot')
    .attr('class', 'line_for_dot')
    .style('stroke', '#D0E3EE')
    .style('stroke-width', '2')
    .attr('x1', 0).attr('x2', 0).attr('y1', height).attr 'y2', 0

  line_for_dot = d3.select('#line_for_dot')
  svg.selectAll('dot').data(data).enter().append('circle').attr('r', 0).attr('data-y-value', (d, i) ->
    y d.close
  ).attr('class', (d, i) ->
    'mark_v3 '
    #return 'mark_v3 ' + (i == 0 || (i == data.length - 1) ? ' hidden' : '');
  ).attr('id', (d, i) ->
    'dot_' + i
  ).attr('cx', (d) ->
    x d.date
  ).attr 'cy', (d) ->
    y d.close

  svg.append('circle')
    .attr('r', 10)
    .attr('id', 'big_dot')
    .attr('class', 'big_dot mark_v2')
    .attr('cx', 0).attr 'cy', 0

  tracing_anim_duration = 150
  distance = x(data[0].date) - x(data[1].date)

  big_dot = d3.select('#big_dot')
  i = 0
  prevTracingDot = undefined

  while i < data.length
    svg.append('rect')
    .attr('class', 'graph-tracing-catcher tracingCatcher')
    .attr('data-dot', '#dot_' + ((parseInt(data.length) - i) - 1))
    .style('opacity', 0)
    .attr('x', ->
      width - x(data[i].date)
    ).attr('y', 0)
    .attr("width", width / data.length)
    .attr('height', height)
    .style('transform', 'translate(' + distance / -2 + 'px)')
    i++
  return

draw_dashboard_general_graph = (el, data_files) ->
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
  DATA_GROUP = 'week'

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

#    if data_files[vm.activeFamilyGraph].data.length > 0
#      distance = area_x(data_files[vm.activeFamilyGraph].data[0].date) - area_x(data_files[vm.activeFamilyGraph].data[1].date) or 0
#    else
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

draw_donut_chart = (el, data) ->
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

draw_block_chart = (el, data) ->
  return if not data
  console.log data
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

  el.empty()

  margin =
    top: 0
    right: 0
    bottom: 0
    left: 0

  # Calculate width/height of svg
  width = el.width() - (margin.left) - (margin.right)
  height = el.height() - (margin.top) - (margin.bottom)

  # Parse date function
  parseDate = d3.time.format(getFormatOfDate()).parse

  #
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


  value = parseFloat(data['value'])
  diff = parseFloat(data['diff'])

  value = 0 if value is 'NaN'

  svg = d3.select(el[0])
    .append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top + margin.bottom)
    .append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

  el.parent().parent().children('.graph-value').children('.val').html value
  el.parent().parent().children('.graph-value').children('.graph-dynamica').removeClass('dynamica_up dynamica_down').addClass if /-/g.test(data['diff']) then 'dynamica_down' else 'dynamica_up'
  el.parent().parent().children('.graph-value').children('.graph-dynamica').html diff

  data['data'] = avgBuilder(data['data'], 10)

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

window.onload = ->
  data = JSON.parse($('chart-data').attr('value'))
  chart_type = $('chart-type').attr('value')

  t =
    diff: data['diff']
    value: data['value']
    data: data['data']

  switch chart_type
    when 'big'
      draw_general_graph($('.areaChartTotal_1'), data)
    when 'block'
      draw_block_chart($('.lineAreaChart_1'), data)
    when 'donut'
      draw_donut_chart($('.donutChart_1'), data)

