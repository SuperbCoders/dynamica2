class DashboardController
  constructor: (@rootScope, @scope, @Projects, @Charts) ->
    vm = @
    vm.params = @rootScope.$stateParams
    vm.project = {}
    vm.range =
      date: undefined
      period: "0"
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
    )

    @scope.$watch('vm.range.date', (old_v, new_v) -> vm.Charts.full_chart_data() )
    @scope.$watch('vm.range.chart', (old_v, new_v) -> vm.Charts.full_chart_data() )

    @scope.$on('$destroy', -> $('.page').removeClass('dashboard_page') )

    @Projects.search({slug: vm.params.slug}).$promise.then( (project) ->
      vm.project = project
      vm.Charts.set_project(vm.project)
      vm.Charts.set_range(vm.range)
    )


  # - - - - - - - - - - - - - - - - CUT HERE - - - - - - - - - - - - - - -
  chart_changed: (chart_type) ->
    value = @range[chart_type]
    @range.general_charts = undefined
    @range.customer_charts = undefined
    @range.product_charts = undefined
    @range[chart_type] = value
    @range.chart = @range[chart_type]

  period_changed: ->
    vm = @
    return if vm.range.period not in ["0","1","2","3","4","5"]
    return if not vm.datepicker

    period = parseInt(vm.range.period)
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


@application.controller 'DashboardController', ['$rootScope', '$scope', 'Projects', 'Charts', DashboardController]

