resizeHndl = undefined
activeFamilyGraph = 0
dataFixture = []

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
      #console.log('break', arr.length, i, part, obj.length);
      break
    i += part
  ret

loadGraphData = ->
  console.log 'loadGraphData'
  $('.pageOverlay').addClass 'show_overlay'
  setTimeout (->
    $('.pageOverlay').removeClass 'show_overlay'
    return
  ), 1500
  return

fit2Limits = (pckr, date, max) ->
  start = moment(pckr.datepicker('getStartDate'))
  end = moment(pckr.datepicker('getEndDate'))
  if max
    moment.max(start, date).startOf('day')._d
  else
    moment.min(end, date).startOf('day')._d

init_charts = ->
  big_chart = [
    {
      'name': 'Revenue'
      'color': '#6AFFCB'
      'value': '35,489$'
      'diff': '+8%'
      'data': [
        {
          'date': '9-Apr-12'
          'close': 180
        }
        {
          'date': '8-Apr-12'
          'close': 260
        }
        {
          'date': '7-Apr-12'
          'close': 218
        }
        {
          'date': '6-Apr-12'
          'close': 308
        }
        {
          'date': '5-Apr-12'
          'close': 400
        }
        {
          'date': '4-Apr-12'
          'close': 220
        }
        {
          'date': '3-Apr-12'
          'close': 329
        }
        {
          'date': '2-Apr-12'
          'close': 150
        }
      ]
    }
    {
      'name': 'Orders'
      'color': '#FF1FA7'
      'value': '490'
      'diff': '-9%'
      'data': [
        {
          'date': '9-Apr-12'
          'close': 240
        }
        {
          'date': '8-Apr-12'
          'close': 290
        }
        {
          'date': '7-Apr-12'
          'close': 368
        }
        {
          'date': '6-Apr-12'
          'close': 308
        }
        {
          'date': '5-Apr-12'
          'close': 150
        }
        {
          'date': '4-Apr-12'
          'close': 264
        }
        {
          'date': '3-Apr-12'
          'close': 120
        }
        {
          'date': '2-Apr-12'
          'close': 250
        }
      ]
    }
    {
      'name': 'Products sell'
      'color': '#FF7045'
      'value': '9,483'
      'diff': '-9%'
      'data': [
        {
          'date': '9-Apr-12'
          'close': 340
        }
        {
          'date': '8-Apr-12'
          'close': 290
        }
        {
          'date': '7-Apr-12'
          'close': 368
        }
        {
          'date': '6-Apr-12'
          'close': 208
        }
        {
          'date': '5-Apr-12'
          'close': 313
        }
        {
          'date': '4-Apr-12'
          'close': 264
        }
        {
          'date': '3-Apr-12'
          'close': 129
        }
        {
          'date': '2-Apr-12'
          'close': 218
        }
      ]
    }
    {
      'name': 'Unic users'
      'color': '#3BD7FF'
      'value': '109,330'
      'diff': '-1%'
      'data': [
        {
          'date': '9-Apr-12'
          'close': 326
        }
        {
          'date': '8-Apr-12'
          'close': 200
        }
        {
          'date': '7-Apr-12'
          'close': 318
        }
        {
          'date': '6-Apr-12'
          'close': 308
        }
        {
          'date': '5-Apr-12'
          'close': 120
        }
        {
          'date': '4-Apr-12'
          'close': 300
        }
        {
          'date': '3-Apr-12'
          'close': 250
        }
        {
          'date': '2-Apr-12'
          'close': 155
        }
      ]
    }
    {
      'name': 'Customers'
      'color': '#FFD865'
      'value': '477'
      'diff': '+2'
      'data': [
        {
          'date': '9-Apr-12'
          'close': 126
        }
        {
          'date': '8-Apr-12'
          'close': 300
        }
        {
          'date': '7-Apr-12'
          'close': 218
        }
        {
          'date': '6-Apr-12'
          'close': 108
        }
        {
          'date': '5-Apr-12'
          'close': 213
        }
        {
          'date': '4-Apr-12'
          'close': 364
        }
        {
          'date': '3-Apr-12'
          'close': 129
        }
        {
          'date': '2-Apr-12'
          'close': 418
        }
      ]
    }
  ]
  init_donut_chart $('.donutChart_1')
  $('.areaChartFamily_1').each (ind) ->
    init_area_family_chart $(this), big_chart
    return
  $('.areaChart_1').each (ind) ->
    init_area_chart $(this)
    return
  $('.areaChart_2').each (ind) ->
    init_line_chart $(this)
    return
  $('.lineAreaChart_1').each (ind) ->
    init_line_area_chart $(this), (el) ->
      el.parent().addClass 'animated fadeInUp'
      return
    return
  $('.areaChart_3').each (ind) ->
    init_line_area2_chart $(this)
    return
  return

init_line_area2_chart = (el) ->
  el.empty()
  margin =
    top: 0
    right: 0
    bottom: 0
    left: 0
  width = el.width() - (margin.left) - (margin.right)
  height = el.height() - (margin.top) - (margin.bottom)
  data = [
    436
    221
    313
    264
    229
    218
  ]
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

init_line_area_chart = (el, callback) ->
  el.empty()
  margin =
    top: 0
    right: 0
    bottom: 0
    left: 0
  width = el.width() - (margin.left) - (margin.right)
  height = el.height() - (margin.top) - (margin.bottom)
  parseDate = d3.time.format('%d-%b-%y').parse
  x = d3.time.scale().range([
    0
    width
  ])
  y = d3.scale.linear().range([
    height
    0
  ])
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
  valueline = d3.svg.line().x((d) ->
    #console.log(d);
    x d.date
  ).y((d) ->
    #console.log(d);
    y d.close
  )
  #.interpolate("cardinal");
  svg = d3.select(el[0]).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
  data = [
    {
      'date': '9-Apr-12'
      'close': 436
    }
    {
      'date': '7-Apr-12'
      'close': 221
    }
    {
      'date': '5-Apr-12'
      'close': 313
    }
    {
      'date': '4-Apr-12'
      'close': 264
    }
    {
      'date': '3-Apr-12'
      'close': 229
    }
    {
      'date': '2-Apr-12'
      'close': 218
    }
    {
      'date': '1-Apr-12'
      'close': 436
    }
  ]
  data = avgBuilder(dataFixture, 10)
  # Get the data
  data.forEach (d) ->
    d.date = parseDate(moment(d.date).format('D-MMM-YY'))
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
  if typeof callback == 'function'
    callback el
  return

init_line_chart = (el) ->
  el.empty()
  margin =
    top: 0
    right: 0
    bottom: 0
    left: 0
  width = el.width() - (margin.left) - (margin.right)
  height = el.height() - (margin.top) - (margin.bottom)
  parseDate = d3.time.format('%d-%b-%y').parse
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
  data = [
    {
      'date': '9-Apr-12'
      'close': 436
    }
    {
      'date': '7-Apr-12'
      'close': 221
    }
    {
      'date': '5-Apr-12'
      'close': 313
    }
    {
      'date': '4-Apr-12'
      'close': 264
    }
    {
      'date': '3-Apr-12'
      'close': 229
    }
    {
      'date': '2-Apr-12'
      'close': 218
    }
  ]
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
  svg.append('path').attr('class', 'line').attr('id', 'blueLine').attr 'd', valueline(data)
  return

init_area_family_chart = (el, data_files, data_colors) ->
  el.find('svg').remove()
  legendBlock = el.parents('.graph-unit').find('.legend_v2')
  if !legendBlock.length
    legendBlock = $('<ul class="legend_v2 graph-unit-legend" />')
    el.parents('.graph-unit').append legendBlock
  legendBlock.empty()
  dates = []
  values = []
  i = 0
  while i < data_files[0].data.length
    obj = data_files[0].data[i]
    dates.push moment(obj.date)
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
    #console.log(d);
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
  xAxis = d3.svg.axis().scale(area_x).ticks(dates.length - 1).tickFormat(d3.time.format('%b %d')).orient('bottom')
  #var xScale = d3.scale.ordinal()
  #    .domain(d3.range(dataset.length))
  #    .rangeRoundBands([0, w], 0.05);
  svg = d3.select(el[0]).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')').on('mousemove', (d) ->
    `var i`
    `var tooltip`
    #console.log(d3.mouse(this));
    tooltip = d3.select('#tooltip')
    tooltip_content = $('#tooltip_content')
    tooltip_dot = $('#tooltip_dot')
    tool_table = $('<table class="graph-tooltip-table" />')
    distance = area_x(data_files[activeFamilyGraph].data[0].date) - area_x(data_files[activeFamilyGraph].data[1].date) or 0
    x = d3.mouse(this)[0] + distance / 2
    x0 = area_x.invert(x)
    ind = undefined
    while k < dates.length
      obj1 = dates[k]
      if moment(x0).startOf('day').isSame(obj1, 'day')
        ind = k
        break
      k++
    while j < data_files.length
      color = data_files[j].color
      data = data_files[j].data
      #var i = bisectDate(data, x0, 1);
      tooltip_item = $('<tr class="tooltip_row" />').attr('data-graph', 'family_area_' + j).addClass(if j == activeFamilyGraph then 'active_row' else '').addClass(if $('.graph-unit-legend .legend_item[data-graph=#family_area_' + j + ']').hasClass('disabled') then 'disabled' else '').append($('<td class="tooltip_name" />').append($('<div class="legend_name" />').css('color', color).append($('<span/>').text(data_files[j].name)))).append($('<td class="tooltip_val" />').append($('<b class="" />').text(data_files[j].data[ind].close)))
      tool_table.append tooltip_item
      j++
    tooltip_content.empty().append($('<div class="tooltip-title" />').text(moment(x0).format('dddd, D MMMM YYYY'))).append tool_table
    tooltip.classed('flipped_left', x < tooltip_content.outerWidth() + 25).style 'left', area_x(data_files[activeFamilyGraph].data[ind].date) + 'px'
    tooltip_dot.css 'top', margin.top + area_y(data_files[activeFamilyGraph].data[ind].close) - 11
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
      `var i`
    i++
  i = 0
  while i < data_files.length
    svg.append('rect').attr('class', 'graph-hover-catcher hoverCatcher').attr('data-area', '#family_area_' + i).style('opacity', 0).attr('transform', 'translate(0,-' + margin.top + ')').attr('x', 0).attr('y', i * 100 / data_files.length + '%').attr('width', '100%').attr 'height', 100 / data_files.length + '%'
    i++
  return

init_area_chart = (el) ->
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
  d3.tsv 'data.tsv', (error, data) ->
    if error
      throw error
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
    gradient = svg.append('svg:defs').append('svg:linearGradient').attr('id', 'area_gradient_1').attr('x1', '0%').attr('y1', '0%').attr('x2', '0%').attr('y2', '100%').attr('spreadMethod', 'pad')
    gradient.append('svg:stop').attr('offset', '0%').attr('stop-color', '#dfe7ff').attr 'stop-opacity', 1
    gradient.append('svg:stop').attr('offset', '100%').attr('stop-color', '#f6f6f6').attr 'stop-opacity', 0
    svg.append('path').datum(data).attr('class', 'area area_v1').attr('d', area).style 'fill', 'url(#area_gradient_1)'
    return
  return

init_donut_chart = (el) ->
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
  d3.csv 'customers_data.csv', type, (error, data) ->
    if error
      throw error
    g = svg.selectAll('.arc').data(pie(data)).enter().append('g').attr('class', 'arc')
    g.append('path').attr('d', arc).style 'fill', (d) ->
      color = d.data.color
      legendItem = $('<li class="legend_item" />').append($('<div class="legend_name" />').css('color', color).append($('<span/>').text(d.data.name))).append($('<div class="legend_val" />').text(d.data.value))
      el.next().append legendItem
      color
    return
  return

$ ($) ->
  i = 0
  while i < 95
    date = moment().subtract(i, 'd')
    dataFixture.push
      'date': date.format('D') + '-' + date.format('MMM') + '-' + date.format('YY')
      'close': (Math.random() * 1000).toFixed(0)
    i++
  $('.datePicker').each ->
    datePckr = $(this)
    datePckr.datepicker(
      multidate: 3
      toggleActive: true
      startDate: '-477d'
      endDate: '0'
      orientation: 'bottom left'
      format: 'M dd, yyyy'
      container: datePckr.parent()
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
            dates[1]
            dates[0]
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
    ).on('show', (e) ->
      calendar = $(this).datepicker('widget')
      dates = e.dates
      if calendar.find('.btn').length
        return
      buttonPane = $('<span class="calendar-control-holder" />')
      setTimeout (->
        btn = $('<a class="apply-calendar-btn_ btn btn-block btn-danger" >Показать</a>')
        btn.off('click').on 'click', ->
          loadGraphData()
          false
        buttonPane.appendTo calendar
        btn.appendTo buttonPane
        return
      ), 1
      return
    ).on 'changeDate', (e, w) ->
    return
  $('body').delegate('.bootstrap-select.filterSelect', 'hide.bs.dropdown', ->
    $(this).closest('.hover-select-box').removeClass 'opened'
    return
  ).delegate('.bootstrap-select.filterSelect', 'click', ->
    $(this).closest('.hover-select-box').addClass 'opened'
    return
  ).delegate('.filter-mod.hover-select-box .filterSelect.selectpicker', 'change', ->
    $(this).closest('.filter-holder').addClass('current').siblings().removeClass 'current'
    return
  ).delegate('.hoverCatcher', 'mouseenter', ->
    firedEl = $($(this).attr('data-area'))
    activeFamilyGraph = $(this).attr('data-area').replace(/\D/g, '') * 1
    firedEl.css('opacity', 1).siblings('.area').css 'opacity', .15
    return
  ).delegate '.hoverCatcher', 'mouseleave', ->
    firedEl = $($(this).attr('data-area'))
    firedEl.css('opacity', .5).siblings('.area').css 'opacity', .5
    return

  $('.graphFilterDate').on('change', ->
    firedEl = $(this)
    datePckr = firedEl.closest('.datepickerComponent').find('.datePicker')
    rangeStart = undefined
    rangeEnd = undefined
    newRange = firedEl.val()
    today = moment()
    if newRange == 0
      #  Current month       
      rangeStart = moment(today).startOf('month')
      rangeEnd = moment(today).endOf('month')
    else if newRange == 1
      #  Previous month 
      rangeStart = moment(today).subtract(1, 'month').startOf('month')
      rangeEnd = moment(today).subtract(1, 'month').endOf('month')
    else if newRange == 2
      #  Last 3 month 
      rangeStart = moment(today).subtract(3, 'month')
      rangeEnd = moment(today)
    else if newRange == 3
      #  Last 6 month 
      rangeStart = moment(today).subtract(6, 'month')
      rangeEnd = moment(today)
    else if newRange == 4
      #  Last year 
      rangeStart = moment(today).subtract(12, 'month')
      rangeEnd = moment(today)
    else if newRange == 5
      #  All time 
      rangeStart = moment(datePckr.datepicker('getStartDate'))
      rangeEnd = moment(datePckr.datepicker('getEndDate'))
    datePckr.datepicker('setDates', [
      fit2Limits(datePckr, rangeStart, true)
      fit2Limits(datePckr, rangeEnd)
    ]).datepicker 'update'
    return
  ).change()
  return
$(window).resize(->
  clearTimeout resizeHndl
  resizeHndl = setTimeout((->
    init_charts()
    return
  ), 10)
  return
).load ->
  init_charts()
  return

# ---
# generated by js2coffee 2.1.0
