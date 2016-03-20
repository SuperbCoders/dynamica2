resizeHndl = undefined
scrollBottomFixed = undefined
scrollParent = undefined
wnd = undefined
doc = undefined
prevTracingDot = undefined

animEndFunc = (catcher) ->
  console.log catcher.find('.sortCatcher')
  catcher.append $(this).removeClass('sorting').attr('style', '')
  return

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

fetchData = ->
  pckr = $('.datePicker')
  $('.pageOverlay').addClass 'show_overlay'
  pathname = window.location.pathname
  window.history.pushState pathname, 'Title', pathname + '?start_date=' + moment(pckr.datepicker('getDates')[0]).format('YYYY-MM-DD') + '&finish_date=' + moment(pckr.datepicker('getDates')[1]).format('YYYY-MM-DD') + '&chart=' + $('.dashboard').data('chart')
  $.ajax
    url: '/charts_data/full_chart_data?chart=' + $('.dashboard').data('chart') + '&from=' + pckr.datepicker('getDates')[0] + '&to=' + pckr.datepicker('getDates')[1] + '&project_id=' + $('.dashboard').data('project-id')
    dataType: 'Script'
    type: 'get'
  # d3.js("/charts_data/full_chart_data.js?chart=" +
  #         $('.dashboard').data('chart') +
  #         "&from=" + pckr.datepicker('getDates')[0] +
  #         "&to=" + pckr.datepicker('getDates')[1] +
  #         "&project_id=" + $('.dashboard').data('project-id'),
  #         function (error, response) {
  #           if (error) return console.log(error);
  #           $('.dashboard').data('full-chart', response);
  #           drawChart();
  #           $('.pageOverlay').removeClass('show_overlay');
  #       }
  # );
  return

drawChart = ->
  $('.areaChartTotal_1').each (ind) ->
    init_line_area3_chart $(this)
    return
  return

init_line_area3_chart = (el) ->

  make_y_axis = ->
    d3.svg.axis().scale(y).orient('left').ticks 5

  make_x_axis = ->
    d3.svg.axis().scale(x).orient('bottom').ticks 5

  el.find('svg').remove()
  t = $.extend(true, {}, $('.dashboard').data('full-chart'))
  data = t.data or []
  data.reverse()
  # debugger;
  # data = [
  #     {"date": "03-Feb-16", "close": 7000},
  #     {"date": "02-Feb-16", "close": 5000},
  #     {"date": "01-Feb-16", "close": 5000}
  # ];
  dates = []
  values = []
  i = 0
  while i < data.length
    obj = data[i]
    dates.push moment(obj.date)
    values.push obj.close
    i++
  #console.log(Math.min.apply(null, values), Math.max.apply(null, values));
  #console.log(moment.min(data));
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
    #console.log(d);
    d.date
  ).left
  parseDate = d3.time.format('%d-%b-%y').parse
  commasFormatter = d3.format(',.0f')
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
  xAxis = d3.svg.axis().scale(x).ticks(if data.length - 1 > 12 then 12 else data.length - 1).tickFormat(d3.time.format('%b %d')).orient('bottom')
  yAxis = d3.svg.axis().scale(y).ticks(5).tickFormat((d) ->
    value = parseFloat(d).number_with_delimiter(' ')
    if $('.dashboard').data('chart') == 'total_revenu'
      value += ' ' + t['value'].slice(-1)
    if d == 0 then '' else value
  ).orient('left')
  svg = d3.select(el[0]).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
  svg.append('g').attr('class', 'x axis').style('font-size', '14px').style('fill', '#A5ADB3').attr('transform', 'translate(0,' + height + ')').call xAxis
  svg.append('g').attr('class', 'y axis').attr('transform', 'translate(' + -25 + ', 0)').style('font-size', '14px').style('fill', '#A5ADB3').attr('class', 'grid').call yAxis

  ###   svg.append("g")
   .attr("class", "gray_grid")
   .attr("transform", "translate(0," + height + ")")
   .call(make_x_axis()
   .tickSize(-height, 0, 0)
   .tickFormat("")
   );
  ###

  svg.append('g').attr('class', 'gray_grid').call make_y_axis().tickSize(-width, 0, 0).tickFormat('')

  ###svg.append("path")
   .data(data)
   .attr("class", "grid_line")
   .attr("d", line);
  ###

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
    `var i`
    y d.close
  svg.append('circle').attr('r', 7).attr('id', 'big_dot').attr('class', 'big_dot mark_v2').attr('cx', 0).attr 'cy', 0
  tracing_anim_duration = 150
  distance = x(data[0].date) - x(data[1].date)
  big_dot = d3.select('#big_dot')
  i = 0
  while i < data.length
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
        value = parseFloat(y0).number_with_delimiter('&thinsp;')
        if $('.dashboard').data('chart') == 'total_revenu'
          value += '&nbsp;' + t['value'].slice(-1)
        tooltip_content.empty().css('top', cur_dot.attr('data-y-value') * 1 + margin.top - 15 + 'px').append($('<div class="tooltip-title" />').text(moment(x0).format('dddd, D MMMM YYYY'))).append $('<div class="tooltip-value" />').html(value)
        tooltip.css 'left', $this.attr('x') * 1 + margin.left + 'px'
        splashTracing cur_id, if cur_id > prevTracingDot then 'left' else 'right'
      return
    ).on 'mouseleave', (e) ->
      dot_id = d3.select(this).attr('data-dot')
      prevTracingDot = dot_id.replace(/\D/g, '') * 1
      return
    i++
  return

splashTracing = (id, direction) ->
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

$ ($) ->
  $('a.dashboard-panel-link').click (e) ->
    window.location.href = '/projects/' + $('.dashboard').data('project-id') + '?start_date=' + moment($('.datePicker').datepicker('getDates')[0]).format('YYYY-MM-DD') + '&finish_date=' + moment($('.datePicker').datepicker('getDates')[1]).format('YYYY-MM-DD')
    false
  $('.dashboard-panel .selectpicker.filterSelect').change (e) ->
    window.location.href = '/projects/' + $('.dashboard').data('project-id') + '/full_chart?chart=' + $(e.target).val() + '&start_date=' + moment($('.datePicker').datepicker('getDates')[0]).format('YYYY-MM-DD') + '&finish_date=' + moment($('.datePicker').datepicker('getDates')[1]).format('YYYY-MM-DD')
    return
  $('a.graph-u-link').click (e) ->
    window.location.href = '/projects/' + $('.dashboard').data('project-id') + '/full_chart?chart=' + $(e.target).parent().find('.graph_1,.graph_2').attr('id') + '&start_date=' + moment($('.datePicker').datepicker('getDates')[0]).format('YYYY-MM-DD') + '&finish_date=' + moment($('.datePicker').datepicker('getDates')[1]).format('YYYY-MM-DD')
    false
  if $('#full_chart').length == 0
    return
  $('ul.dashboard-panel > li').removeClass 'current'
  $('.selectpicker.filterSelect').each ->
    $(this).children('option').each ->
      if $(this).val() == $('.dashboard').data('chart')
        $(this).closest('li').addClass 'current'
      return
    return
  wnd = $(window)
  doc = $(document)
  scrollParent = $('.scrollParent')
  scrollBottomFixed = $('.scrollBottomFixed')
  $('.datePicker').each ->
    datePckr = $(this)
    datePckr.datepicker(
      multidate: 3
      toggleActive: true
      startDate: $('.dashboard').data('start-date')
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
    ).on('show', (e) ->
      calendar = $('.datepicker.datepicker-dropdown.dropdown-menu')
      if calendar.find('.btn').length
        return
      buttonPane = $('<span class="calendar-control-holder" />')
      setTimeout (->
        btn = $('<a class="apply-calendar-btn_ btn btn-block btn-danger" >Показать</a>')
        btn.off('click').on 'click', ->
          fetchData()
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
  ).delegate '.bootstrap-select.filterSelect', 'click', ->
    $(this).closest('.hover-select-box').addClass 'opened'
    return
  $('.sortHeader').on 'click', (e) ->
    firedEl = $(this)
    sortBtn = firedEl.closest('.sortBlock').find('.sortBtn')
    if sortBtn.hasClass('sorting')
      return
    if $(e.target).hasClass('sortBtn')
      $(e.target).toggleClass 'sort_desc'
    else
      if firedEl.find('.sortBtn').length
        firedEl.find('.sortBtn').toggleClass 'sort_desc'
      else
        sortBtn.one 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', ->
          firedEl.find('.sortCatcher').append $(this).removeClass('sorting').attr('style', '')
          return
        sortBtn.addClass('sorting').css 'left', firedEl.find('.sortCatcher').offset().left - (sortBtn.offset().left) + sortBtn.css('marginLeft').replace('px', '') * 1
    pckr = $('.datePicker')
    sort_by = $(this).attr('id')
    sort_direction = if $('.sort_desc').length == 1 then 'asc' else 'desc'
    # reverse
    $('.pageOverlay').addClass 'show_overlay'
    $.ajax
      url: '/charts_data/sorted_full_chart_data?chart=' + $('.dashboard').data('chart') + '&from=' + pckr.datepicker('getDates')[0] + '&to=' + pckr.datepicker('getDates')[1] + '&project_id=' + $('.dashboard').data('project-id') + '&' + sort_by + '=' + sort_direction
      dataType: 'Script'
      type: 'get'
    return
  $('.graphFilterDate').on('change', ->
    firedEl = $(this)
    datePckr = firedEl.closest('.datepickerComponent').find('.datePicker')
    rangeStart = undefined
    rangeEnd = undefined
    newRange = firedEl.val()
    today = moment()
    if $('.dashboard').data('date-from') and $('.dashboard').data('date-to')
      rangeStart = moment($('.dashboard').data('date-from'))
      rangeEnd = moment($('.dashboard').data('date-to'))
      $('.dashboard').data 'date-to', null
    else
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
    if $('.datePicker').datepicker('getDates').length == 2
      fetchData()
    return
  ).change()
  return

$(window).resize(->
  if $('#full_chart').length == 0
    return
  clearTimeout resizeHndl
  resizeHndl = setTimeout((->
    drawChart()
    return
  ), 10)
  return
).load(->
  if $('#full_chart').length == 0
    return
  drawChart()
  return
).scroll ->
  if $('#full_chart').length == 0
    return
  if scrollParent.offset().top - doc.scrollTop() + scrollBottomFixed.height() + scrollBottomFixed.css('marginTop').replace('px', '') * 1 <= wnd.height()
    scrollBottomFixed.addClass('table-footer-fixed').removeClass 'table-footer-bottom'
  if scrollParent.offset().top - doc.scrollTop() > wnd.height() - (scrollBottomFixed.height() * 2)
    scrollBottomFixed.removeClass('table-footer-fixed').removeClass 'table-footer-bottom'
  if doc.scrollTop() + wnd.height() - scrollBottomFixed.height() >= scrollParent.offset().top + scrollParent.height()
    scrollBottomFixed.removeClass('table-footer-fixed').addClass 'table-footer-bottom'
  return
