class ProductsRevenueController
  constructor: (@rootScope, @scope, @Projects, @http, @T) ->
    vm = @
    vm.slug = @rootScope.$stateParams.slug
    vm.chart = 'products_revenue'
    vm.project = @rootScope.$stateParams.project
    vm.sortType = ''
    vm.sortReverse = false
    vm.date_range = 0
    vm.range =
      chart: vm.chart
      from: @rootScope.$stateParams.from
      to: @rootScope.$stateParams.to

    vm.datepicker = $('.datePicker')

    @scope.$watch('vm.date_range', (old_val) -> vm.set_date_range(old_val) )

    @rootScope.$state.go('projects.list') if not vm.range.from or not vm.range.to

    @init_dashboard()

    if not @project
      @Projects.search({slug: vm.slug}).$promise.then( (project) ->
        vm.project = project
        vm.fetch()
      )
    else
      @fetch()

  datepicker_changed: ->
    vm = @
    dates = vm.datepicker_date.split(' – ')

    if dates.length == 2
      vm.range.raw_start = moment(dates[0])
      vm.range.raw_end = moment(dates[1])
      vm.range.from = vm.range.raw_start.format('MM.DD.YYYY')
      vm.range.to = vm.range.raw_end.format('MM.DD.YYYY')
      vm.fetch()

  fetch: ->
    vm = @

    return if not vm.project

    chart_url = "/charts_data/products_characteristics"
    chart_params =
      from: vm.range.from
      to: vm.range.to
      project_id: vm.project.id
      chart: vm.chart

    vm.sales = 0
    vm.gross_revenue = 0
    vm.http.get(chart_url, params: chart_params).success((response) ->
      for p in response
        vm.sales += p.sales
        vm.gross_revenue += p.gross_revenue

      vm.products = response
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

  set_date_range: (range_type) ->
    vm = @
    return if range_type not in ["1","2","3","4","5", "6"]
    return if not vm.datepicker

    period = parseInt(range_type)
    today = moment()

    if period == 1
      # Current month
      console.log 'Period is Current month'
      rangeStart = moment(today).startOf('month')
      rangeEnd = moment(today).endOf('month')
    else if period == 2
      # Previous month
      console.log 'Period is Previous month'
      rangeStart = moment(today).subtract(1, 'month').startOf('month')
      rangeEnd = moment(today).subtract(1, 'month').endOf('month')
    else if period == 3
      # Last 3 month
      console.log 'Period is Last 3 month'
      rangeStart = moment(today).subtract(3, 'month')
      rangeEnd = moment(today)
    else if period == 4
      # Last 6 month
      console.log 'Period is Last 6 month'
      rangeStart = moment(today).subtract(6, 'month')
      rangeEnd = moment(today)
    else if period == 5
      # Last year
      console.log 'Period is Last year'
      rangeStart = moment(today).subtract(12, 'month')
      rangeEnd = moment(today)
    else if period == 6
      # All time
      console.log 'Period is All time'
      rangeStart = moment(vm.datepicker.datepicker('getStartDate'))
      rangeEnd = moment(vm.datepicker.datepicker('getEndDate'))

    vm.range.raw_start = rangeStart
    vm.range.raw_end = rangeEnd
    vm.range.from = rangeStart.format('MM.DD.YYYY')
    vm.range.to = rangeEnd.format('MM.DD.YYYY')

    vm.set_datepicker_date(rangeStart, rangeEnd)
    vm.fetch()
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
      startDate: '-730d'
      endDate: '0'
      toggleActive: true
      orientation: 'bottom left'
      format: 'M dd, yyyy'
      container: $('.datePicker').parent()
      multidateSeparator: ' – ')

    wnd = $(window)
    scrollParent = $('.scrollParent')
    doc = $(document)
    scrollBottomFixed = $('.scrollBottomFixed')

    $(window).scroll ->
      if scrollParent.offset().top - doc.scrollTop() + scrollBottomFixed.height() + scrollBottomFixed.css('marginTop').replace('px', '') * 1 <= wnd.height()
        scrollBottomFixed.addClass('table-footer-fixed').removeClass 'table-footer-bottom'
      if scrollParent.offset().top - doc.scrollTop() > wnd.height() - (scrollBottomFixed.height() * 2)
        scrollBottomFixed.removeClass('table-footer-fixed').removeClass 'table-footer-bottom'
      if doc.scrollTop() + wnd.height() - scrollBottomFixed.height() >= scrollParent.offset().top + scrollParent.height()
        scrollBottomFixed.removeClass('table-footer-fixed').addClass 'table-footer-bottom'



  parse_diff: (diff_str) -> parseInt(diff_str)
  chart_changed: (chart) -> @rootScope.$state.go('projects.chart', {project: @project,slug: @project.slug,chart: @range[chart],from: @range.from,to: @range.to})
  toggle_debug: -> if @debug is true then @debug = false else @debug = true
@application.controller 'ProductsRevenueController', ['$rootScope', '$scope', 'Projects', '$http', 'Translate', ProductsRevenueController]
