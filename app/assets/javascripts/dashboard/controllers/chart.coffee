class ChartController
  constructor: (@rootScope, @scope, @Projects, @http, @T) ->
    console.log 'ChartController constructor'
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

    chart_url = "/charts_data/full_chart_data"
    chart_params =
      from: vm.range.from
      to: vm.range.to
      project_id: vm.project.id
      chart: vm.chart

    vm.http.get(chart_url, params: chart_params).success((response) ->
        vm.data = response['full']
        vm.check_points = response['check_points']
        vm.table_data = {}
        vm.table_keys = []

        _.forEach(response['table_data'], (value, chart_name) ->

          # Save chart name
          vm.table_keys.push chart_name if chart_name not in vm.table_keys

          # forEach chart data
          _.forEach(value['data'], (close, date) ->

            vm.table_data[date] = {} if not vm.table_data[date]

            table = vm.table_data[date]

            table[chart_name] = 0 if not table[chart_name]

            table[chart_name] += close

          )

        )

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
      if d == 0 then '' else currencyFormatter(d) + '$'
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
      d.close = +d.close

    # Scale the range of the data
    x.domain d3.extent(data, (d) -> d.date)
    area_x.domain d3.extent(data, (d) -> d.date)

    y.domain [ 0,d3.max(data, (d) -> Math.max d.close) ]
    area_y.domain [ 0, d3.max(data, (d) -> d.close)]

    svg.append('path').attr('class', 'line').attr 'd', valueline(data)

    # Add the scatterplot
    svg.append('line').attr('id', 'line_for_dot').attr('class', 'line_for_dot').style('stroke', '#D0E3EE').style('stroke-width', '2').attr('x1', 0).attr('x2', 0).attr('y1', height).attr 'y2', 0
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
    svg.append('circle').attr('r', 10).attr('id', 'big_dot').attr('class', 'big_dot mark_v2').attr('cx', 0).attr 'cy', 0
    tracing_anim_duration = 150
    distance = x(data[0].date) - x(data[1].date)
    console.log 'Disatance '+distance
    big_dot = d3.select('#big_dot')
    i = 0
    prevTracingDot = undefined

    while i < data.length
      svg.append('rect')
        .attr('class', 'graph-tracing-catcher tracingCatcher')
        .attr('data-dot', '#dot_' + data.length - i - 1)
        .style('opacity', 0)
        .attr('x', ->
        width - x(data[i].date)
      ).attr('y', 0)
        .attr('width', width)
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

          tooltip_content
            .empty()
            .css('top', cur_dot.attr('data-y-value') * 1 + margin.top - 15 + 'px')
            .append($('<div class="tooltip-title" />')
            .text(moment(x0).format('dddd, D MMMM YYYY')))
            .append($('<div class="tooltip-value" />').text(currencyFormatter(y0) + '$'))

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

    console.log 'Current id '+id+' direction '+direction

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
