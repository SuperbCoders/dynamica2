class ChartController
  constructor: (@rootScope, @scope, @Projects, @http) ->
    vm = @
    vm.slug = @rootScope.$stateParams.slug
    vm.chart = @rootScope.$stateParams.chart
    vm.project = @rootScope.$stateParams.project
    vm.range =
      from: @rootScope.$stateParams.from
      to: @rootScope.$stateParams.to

    vm.datepicker = $('.datePicker')

    if not vm.range.from or not vm.range.to
      @rootScope.$state.go('projects.list')

    @init_dashboard()
    @set_range()

    if not @project
      @Projects.search({slug: vm.slug}).$promise.then( (project) ->
        vm.project = project
        @fetch()
      )
    else
      @fetch()



  charts_fetch: (chart_type) ->
    vm = @

    chart_url = "/charts_data/#{chart_type}"
    chart_params =
      from: vm.range.from
      to: vm.range.to
      project_id: vm.project.id
      chart: vm.chart

    vm.http.get chart_url, params: chart_params

  fetch: ->
    return unless @project.id
    vm = @
    @charts_fetch('full_chart_data').success((response) ->
      vm.data = response
    )

  fit2Limits: (pckr, date, max) ->
    start = moment(pckr.datepicker('getStartDate'))
    end = moment(pckr.datepicker('getEndDate'))
    if max
      moment.max(start, date).startOf('day')._d
    else
      moment.min(end, date).startOf('day')._d

  set_range: ->
    vm = @
    vm.range.raw_start = rangeStart = moment(vm.range.from)
    vm.range.raw_end = rangeEnd = moment(vm.range.to)

    vm.datepicker.datepicker('setDates', [
      vm.fit2Limits(vm.datepicker, rangeStart, true)
      vm.fit2Limits(vm.datepicker, rangeEnd)
    ]).datepicker 'update'

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


  toggle_debug: -> if @debug is true then @debug = false else @debug = true
@application.controller 'ChartController', ['$rootScope', '$scope', 'Projects', '$http', ChartController]
