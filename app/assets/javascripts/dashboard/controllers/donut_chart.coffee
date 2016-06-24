class DonutChartController
  constructor: (@rootScope, @scope, @Projects, @http, @filter) ->
    console.log 'DonutChartController constructor.'
    console.log 'From : '+@rootScope.$stateParams.from
    console.log 'To : '+@rootScope.$stateParams.to

    vm = @
    vm.slug = @rootScope.$stateParams.slug
    vm.chart = @rootScope.$stateParams.chart
    vm.project = @rootScope.$stateParams.project
    vm.itemsPerPage = 50
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
    @rootScope.load_dates_from_ls(vm)

    if not vm.range.from and not vm.range.to
      vm.range.raw_start = rangeStart = moment(vm.range.from, 'MM.DD.YYYY')
      vm.range.raw_end = rangeEnd = moment(vm.range.to, 'MM.DD.YYYY')
      vm.range.from = rangeStart.format('MM.DD.YYYY')
      vm.range.to = rangeEnd.format('MM.DD.YYYY')

    @Projects.search({slug: vm.slug}).$promise.then( (project) ->
      vm.project = project
      vm.rootScope.current_project(vm.project)
      vm.rootScope.currency = vm.project.currency
      vm.rootScope.set_datepicker_start_date(vm.datepicker, vm.project.first_project_data)
      vm.rootScope.set_datepicker_date(vm.datepicker, vm.range.raw_start, vm.range.raw_end)
    )

  table_data_array: ->
    vm = @
    result = []
    angular.forEach vm.table_data, (value, key) ->
      value['date'] = key
      result.push value
    result

  fetch: ->
    vm = @

    return if not vm.project

    chart_url = "/charts_data/full_donut_chart_data"
    chart_params =
      from: vm.range.from
      to: vm.range.to
      project_id: vm.project.id
      chart: vm.chart

    vm.http.get(chart_url, params: chart_params).success((response) ->
        race = {
          "items": {"delivered": "#975e16", "canceled": "#b92784", "transit": "#a0569a", "new": "#9043a9"},
          "data": [
            {"key": "AR", "value": "0.1", "date": "01/08/13"},
            {"key": "AR", "value": "0.15", "date": "01/09/13"},
            {"key": "AR", "value": "0.35", "date": "01/10/13"},
            {"key": "AR", "value": "0.38", "date": "01/11/13"},
            {"key": "AR", "value": "0.22", "date": "01/12/13"}, {
              "key": "AR",
              "value": "0.16",
              "date": "01/13/13"
            }, {"key": "AR", "value": "0.07", "date": "01/14/13"}, {
              "key": "AR",
              "value": "0.02",
              "date": "01/15/13"
            }, {"key": "AR", "value": "0.17", "date": "01/16/13"}, {
              "key": "AR",
              "value": "0.33",
              "date": "01/17/13"
            }, {"key": "AR", "value": "0.4", "date": "01/18/13"}, {
              "key": "AR",
              "value": "0.32",
              "date": "01/19/13"
            }, {"key": "AR", "value": "0.26", "date": "01/20/13"}, {
              "key": "AR",
              "value": "0.35",
              "date": "01/21/13"
            }, {"key": "AR", "value": "0.4", "date": "01/22/13"}, {
              "key": "AR",
              "value": "0.32",
              "date": "01/23/13"
            }, {"key": "AR", "value": "0.26", "date": "01/24/13"}, {
              "key": "AR",
              "value": "0.22",
              "date": "01/25/13"
            }, {"key": "AR", "value": "0.16", "date": "01/26/13"}, {
              "key": "AR",
              "value": "0.22",
              "date": "01/27/13"
            }, {"key": "AR", "value": "0.1", "date": "01/28/13"}, {
              "key": "DJ",
              "value": "0.35",
              "date": "01/08/13"
            }, {"key": "DJ", "value": "0.36", "date": "01/09/13"}, {
              "key": "DJ",
              "value": "0.37",
              "date": "01/10/13"
            }, {"key": "DJ", "value": "0.22", "date": "01/11/13"}, {
              "key": "DJ",
              "value": "0.24",
              "date": "01/12/13"
            }, {"key": "DJ", "value": "0.26", "date": "01/13/13"}, {
              "key": "DJ",
              "value": "0.34",
              "date": "01/14/13"
            }, {"key": "DJ", "value": "0.21", "date": "01/15/13"}, {
              "key": "DJ",
              "value": "0.18",
              "date": "01/16/13"
            }, {"key": "DJ", "value": "0.45", "date": "01/17/13"}, {
              "key": "DJ",
              "value": "0.32",
              "date": "01/18/13"
            }, {"key": "DJ", "value": "0.35", "date": "01/19/13"}, {
              "key": "DJ",
              "value": "0.3",
              "date": "01/20/13"
            }, {"key": "DJ", "value": "0.28", "date": "01/21/13"}, {
              "key": "DJ",
              "value": "0.27",
              "date": "01/22/13"
            }, {"key": "DJ", "value": "0.26", "date": "01/23/13"}, {
              "key": "DJ",
              "value": "0.15",
              "date": "01/24/13"
            }, {"key": "DJ", "value": "0.3", "date": "01/25/13"}, {
              "key": "DJ",
              "value": "0.35",
              "date": "01/26/13"
            }, {"key": "DJ", "value": "0.42", "date": "01/27/13"}, {
              "key": "DJ",
              "value": "0.42",
              "date": "01/28/13"
            }, {"key": "CG", "value": "0.1", "date": "01/08/13"}, {
              "key": "CG",
              "value": "0.15",
              "date": "01/09/13"
            }, {"key": "CG", "value": "0.35", "date": "01/10/13"}, {
              "key": "CG",
              "value": "0.38",
              "date": "01/11/13"
            }, {"key": "CG", "value": "0.22", "date": "01/12/13"}, {
              "key": "CG",
              "value": "0.16",
              "date": "01/13/13"
            }, {"key": "CG", "value": "0.07", "date": "01/14/13"}, {
              "key": "CG",
              "value": "0.02",
              "date": "01/15/13"
            }, {"key": "CG", "value": "0.17", "date": "01/16/13"}, {
              "key": "CG",
              "value": "0.33",
              "date": "01/17/13"
            }, {"key": "CG", "value": "0.4", "date": "01/18/13"}, {
              "key": "CG",
              "value": "0.32",
              "date": "01/19/13"
            }, {"key": "CG", "value": "0.26", "date": "01/20/13"}, {
              "key": "CG",
              "value": "0.35",
              "date": "01/21/13"
            }, {"key": "CG", "value": "0.4", "date": "01/22/13"}, {
              "key": "CG",
              "value": "0.32",
              "date": "01/23/13"
            }, {"key": "CG", "value": "0.26", "date": "01/24/13"}, {
              "key": "CG",
              "value": "0.22",
              "date": "01/25/13"
            }, {"key": "CG", "value": "0.16", "date": "01/26/13"}, {
              "key": "CG",
              "value": "0.22",
              "date": "01/27/13"
            }, {"key": "CG", "value": "0.1", "date": "01/28/13"}, {
              "key": "RI",
              "value": "0.1",
              "date": "01/08/13"
            }, {"key": "RI", "value": "0.15", "date": "01/09/13"}, {
              "key": "RI",
              "value": "0.35",
              "date": "01/10/13"
            }, {"key": "RI", "value": "0.38", "date": "01/11/13"}, {
              "key": "RI",
              "value": "0.22",
              "date": "01/12/13"
            }, {"key": "RI", "value": "0.16", "date": "01/13/13"}, {
              "key": "RI",
              "value": "0.07",
              "date": "01/14/13"
            }, {"key": "RI", "value": "0.02", "date": "01/15/13"}, {
              "key": "RI",
              "value": "0.17",
              "date": "01/16/13"
            }, {"key": "RI", "value": "0.33", "date": "01/17/13"}, {
              "key": "RI",
              "value": "0.4",
              "date": "01/18/13"
            }, {"key": "RI", "value": "0.32", "date": "01/19/13"}, {
              "key": "RI",
              "value": "0.26",
              "date": "01/20/13"
            }, {"key": "RI", "value": "0.35", "date": "01/21/13"}, {
              "key": "RI",
              "value": "0.4",
              "date": "01/22/13"
            }, {"key": "RI", "value": "0.32", "date": "01/23/13"}, {
              "key": "RI",
              "value": "0.26",
              "date": "01/24/13"
            }, {"key": "RI", "value": "0.22", "date": "01/25/13"}, {
              "key": "RI",
              "value": "0.16",
              "date": "01/26/13"
            }, {"key": "RI", "value": "0.22", "date": "01/27/13"}, {"key": "RI", "value": "0.1", "date": "01/28/13"}]
        }
        vm.draw_stream_graph($('.streamChartTotal'), response, false)
      )

  fit2Limits: (pckr, date, max) ->
    start = moment(pckr.datepicker('getStartDate'))
    end = moment(pckr.datepicker('getEndDate'))
    if max
      moment.max(start, date).startOf('day')._d
    else
      moment.min(end, date).startOf('day')._d

  draw_stream_graph: (el, data_files, needMath) ->

    mouseMoveCatcher = (that) ->
      console.log 'mouseMoveCatcher'
      #console.log(this);
      distance = x(data_files.data[0].date) - x(data_files.data[1].date) or 0
      mouse = d3.mouse(that)
      x0 = mouse[0] - (distance / 2)
      invertedx = x.invert(x0)
      mousedate = datearray.indexOf(invertedx)
      k = 0
      while k < datearray[0].length
        obj1 = datearray[0][k].date
        if moment(invertedx).startOf('day').isSame(moment(obj1), 'day')
          mousedate = k
          break
        k++
      tooltip = d3.select('#tooltip')
      tooltip_content = $('#tooltip_content')
      tooltip_dot = $('#tooltip_dot')
      tool_table = $('<table class="graph-tooltip-table" />')
      j = 0
      while j < datearray.length
        color = colors[j]
        data = datearray[j]
        tooltip_item = $('<tr class="tooltip_row" />').attr('data-graph', 'stream_area_' + j).append($('<td class="tooltip_name" />').append($('<div class="legend_name" />').css('color', color).append($('<span/>').text(data[mousedate].key)))).append($('<td class="tooltip_val" />').append($('<b class="" />').text(data[mousedate].value)))
        tool_table.prepend tooltip_item
        j++
      tooltip_content.empty().append($('<div class="tooltip-title" />').text(moment(invertedx).format('dddd, D MMMM YYYY'))).append tool_table
      tooltip.classed('flipped_left', x0 < tooltip_content.outerWidth() + 35).style 'left', x(invertedx) + margin.left + distance / 2 + 'px'
      return

    # aa
    el.find('svg').remove()
    legendBlock = el.parents('.graph-unit-holder').find('.legend_v2')
    if !legendBlock.length
      legendBlock = $('<ul class="legend_v2 graph-unit-legend" />')
      el.parents('.graph-unit').append legendBlock
    datas = []
    area_x = undefined
    items = data_files.items
    colors = []
    names = []
    if needMath
      i = 0
      while i < data.length
        obj = data[i]
        sum = undefined
        sum = getSum(obj)
        console.log sum
        i++
    item_data = []
    for key of items
      if items.hasOwnProperty(key)
        names.push key
        colors.push items[key]
    tooltip = $('<table class="graph-tooltip-table" />')
    margin =
      top: 30
      right: 35
      bottom: 30
      left: 75
    width = el.width() - (margin.left) - (margin.right)
    height = el.height() - (margin.top) - (margin.bottom)
    datearray = []
    colorrange = [
      '#045A8D'
      '#2B8CBE'
      '#74A9CF'
      '#A6BDDB'
      '#D0D1E6'
      '#F1EEF6'
    ]
    strokecolor = colorrange[0]
    parseDate = d3.time.format('%m/%d/%y')
    data = data_files.data
    for day of data
      if items.hasOwnProperty(key)
        names.push key
        colors.push items[key]
    x = d3.time.scale().range([
      0
      width
    ])
    y = d3.scale.linear().range([
        height - 10
        0
    ])
    z = d3.scale.ordinal().range(colorrange)
    xAxis = d3.svg.axis().scale(x).orient('bottom').ticks(d3.time.days)
    yAxis = d3.svg.axis().scale(y)
    yAxisr = d3.svg.axis().scale(y)
    stack = d3.layout.stack().offset('silhouette').values((d) -> d.values).x((d) -> d.date).y((d) -> d.value)

    nest = d3.nest().key((d) -> d.key)

    area = d3.svg.area().interpolate('cardinal').x((d) ->
        x d.date
      ).y0((d) ->
        y d.y0
      ).y1((d) ->
        y d.y0 + d.y
      )
    svg = d3.select(el[0]).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
    data.forEach (d) ->
      d.date = parseDate.parse(d.date)
      d.value = +d.value
      return
    console.log data
    layers = stack(nest.entries(data))
    x.domain d3.extent(data, (d) ->
      d.date
    )
    y.domain [
      0
      d3.max(data, (d) ->
        d.y0 + d.y
      )
    ]
    svg.append('rect').attr('class', 'click-capture').style('opacity', '0').attr('x', 0).attr('y', 0).attr('width', width).attr('height', height).on 'mousemove', (d) ->
      #console.log('rect');
      mouseMoveCatcher this
      return
    svg.selectAll('.layer').data(layers).enter().append('path').attr('class', 'layer').attr('d', (d) ->
      datearray.push d.values
      area d.values
    ).style 'fill', (d, i) ->
      colors[i]
    svg.append('g').attr('class', 'x axis ').attr('transform', 'translate(0,' + height + ')').call xAxis
    #svg.append("g")
    #    .attr("class", "y axis")
    #    .attr("transform", "translate(" + width + ", 0)")
    #    .call(yAxis.orient("right"));
    svg.append('g').attr('class', 'y axis').call yAxis.orient('left')
    svg.selectAll('.tick').attr('fill', '#a5adb3').attr 'font-size', '14px'
    svg.selectAll('.layer').attr('opacity', 1).attr('data-graph', (d, i) ->
      'stream_area_' + i
    ).on('mouseover', (d, i) ->
      svg.selectAll('.layer').transition().duration(250).attr 'opacity', (d, j) ->
        if j != i then 0.6 else 1
      return
    ).on('mousemove', (d, i) ->
      d3.select(this).classed 'hover', true
      #console.log('layer');
      mouseMoveCatcher this
      return
    ).on 'mouseout', (d, i) ->
      svg.selectAll('.layer').transition().duration(250).attr 'opacity', '1'
      d3.select(this).classed 'hover', false
      return
    return


  draw_donut_graph: (el, data_files) ->
    doc = $(document)
    el.find('svg').remove()
    legendBlock = el.parents('.graph-unit-holder').find('.legend_v2')
    if !legendBlock.length
      legendBlock = $('<ul class="legend_v2 graph-unit-legend" />')
      el.parents('.graph-unit').append legendBlock
    dates = []
    area_x = undefined
    items = data_files.items
    data = data_files.data
    colors = []
    names = []
    for key of items
      if items.hasOwnProperty(key)
        names.push key
        colors.push items[key]
    i = 0
    while i < colors.length
      obj = doc[i]
      i++
    tooltip = $('<table class="graph-tooltip-table" />')
    margin =
      top: 30
      right: 35
      bottom: 30
      left: 75
    width = el.width() - (margin.left) - (margin.right)
    height = el.height() - (margin.top) - (margin.bottom)
    formatPercent = d3.format('.0%')
    parseDate = d3.time.format('%d-%b-%y').parse
    x = d3.time.scale().range([
      0
      width
    ])
    y = d3.scale.linear().range([
      height
      0
    ])
    color = d3.scale.ordinal().domain(names).range(colors)
    xAxis = d3.svg.axis().scale(x).orient('bottom')
    yAxis = d3.svg.axis().scale(y).orient('left').tickFormat(formatPercent).tickValues([
      0
      1
    ])
    area = d3.svg.area().x((d) ->
      x d.date
    ).y0((d) ->
      y d.y0
    ).y1((d) ->
      y d.y0 + d.y
    )
    stack = d3.layout.stack().values((d) ->
      d.values
    )
    svg = d3.select(el[0]).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')').on('mousemove', (d) ->
      `var tooltip`
      `var x`
      `var key`
      tooltip = d3.select('#tooltip')
      tooltip_content = $('#tooltip_content')
      tooltip_dot = $('#tooltip_dot')
      tool_table = $('<table class="graph-tooltip-table" />')
      distance = area_x(data_files.data[0].date) - area_x(data_files.data[1].date) or 0
      x = d3.mouse(this)[0] - (distance / 2)
      x0 = area_x.invert(x)
      ind = undefined
      k = 0
      while k < dates.length
        obj1 = dates[k]
        if moment(x0).startOf('day').isSame(obj1, 'day')
          ind = k
          break
        k++
      p = data_files.data[k]
      index = 0
      for key of p
        if p.hasOwnProperty(key)
          if key != 'date'
            tooltip_item = $('<tr class="tooltip_row" />').append($('<td class="tooltip_name" />').append($('<div class="legend_name" />').css('color', colors[index]).append($('<span/>').text(key)))).append($('<td class="tooltip_val" />').append($('<b class="" />').text(p[key])))
            tool_table.prepend tooltip_item
            index++
      tooltip_content.empty().append($('<div class="tooltip-title" />').text(moment(x0).format('dddd, D MMMM YYYY'))).append tool_table
      tooltip.classed('flipped_left', x < tooltip_content.outerWidth() + 60).style 'left', area_x(data_files.data[k].date) - distance + 'px'
      return
    )
    color.domain d3.keys(data[0]).filter((key) ->
      key != 'date'
    )
    data.forEach (d) ->
      d.date = parseDate(d.date)
      dates.push moment(d.date)
      return
    browsers = stack(color.domain().map((name) ->
      {
      name: name
      values: data.map((d) ->
        {
        date: d.date
        y: d[name] / 100
        }
      )
      }
    ))
    x.domain d3.extent(data, (d) ->
      d.date
    )
    browser = svg.selectAll('.browser').data(browsers).enter().append('g').attr('class', 'browser')
    browser.append('path').attr('class', 'area').attr('d', (d) ->
      area d.values
    ).style 'fill', (d) ->
      color d.name
    svg.append('g').attr('class', 'x axis').attr('transform', 'translate(0,' + height + ')').style('fill', '#a5adb3').style('font-size', '14px').style('font-weight', '300').call(xAxis).selectAll('text').attr 'y', 18
    svg.append('g').attr('class', 'y axis').style('fill', '#a5adb3').style('font-size', '14px').style('font-weight', '300').call(yAxis).selectAll('text').attr('y', 0).attr('x', -75).style 'text-anchor', 'start'
    area_x = d3.time.scale().domain([
      moment.min(dates)
      moment.max(dates)
    ]).range([
      0
      width
    ])
    return

  init_line_area3_chart: (el, data) ->
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
      # d.date == 18-Feb-16
      dates.push moment(d.date, 'DD-MMM-YY')
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
    DATA_GROUP = vm.range.period
    DATE_FORMAT = d3.time.format('%b %d')
    TICKS = 17


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
    distance = x(data[0].date) - x(data[1].date) if data.length > 2

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
      .on('mouseenter', (e) ->
        $this = $(this)
        dot_id = d3.select(this).attr('data-dot')
        cur_id = dot_id.replace(/\D/g, '') * 1
        cur_dot = $('#dot_' + cur_id)
        x0 = area_x.invert(cur_dot.attr('cx'))
        y0 = area_y.invert(cur_dot.attr('cy')).toFixed(0)
        if prevTracingDot != undefined
          big_dot
            .transition()
            .duration(tracing_anim_duration)
            .attr('cx', $this.attr('x'))
            .attr('cy', cur_dot.attr('data-y-value'))

          line_for_dot
            .transition()
            .duration(tracing_anim_duration)
            .attr('x1', $this.attr('x'))
            .attr('x2', $this.attr('x'))
            .attr('y2', cur_dot.attr('data-y-value'))

          value = vm.rootScope.period_value(y0, vm.chart)

          tooltip_content
            .empty()
            .css('top', cur_dot.attr('data-y-value') * 1 + margin.top - 15 + 'px')
            .append($('<div class="tooltip-title" />')
            .text(moment(x0).format('dddd, D MMMM YYYY')))
            .append($('<div class="tooltip-value" />').text(value))

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
      vm.range.raw_start = moment(dates[0], "MMM D, YYYY")
      vm.range.raw_end = moment(dates[1], "MMM D, YYYY")
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

    switch direction
      when 'right'
        setTimeout (->
          $('#dot_' + id + 1).attr('r', new_r)
          return
        ), 50

        setTimeout (->
          $('#dot_' + id * 1 + 1).attr('r', 0)
          return
        ), 350
      when 'left'
        setTimeout (->
          $('#dot_' + id - 1).attr('r', new_r)
          return
        ), 50

        setTimeout (->
          $('#dot_' + id * 1 - 1).attr('r', 0)
          return
        ), 350
    return

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


  period_value: (value) -> @rootScope.period_value(value, @chart)

  state_is: (name) -> @rootScope.state_is(name)
  parse_diff: (diff_str) -> parseInt(diff_str)
  chart_changed: (chart) -> @rootScope.$state.go('projects.chart', {project: @project,slug: @project.slug,chart: @range[chart],from: @range.from,to: @range.to})
  toggle_debug: -> if @debug is true then @debug = false else @debug = true

@application.controller 'DonutChartController', ['$rootScope', '$scope', 'Projects', '$http', '$filter', DonutChartController]
